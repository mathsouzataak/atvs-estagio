public with sharing class CalloutOrder {
	/**
	 * Execute a callout to upsert orders
	 * @param orderIdList List of Order Ids to be sent in the callout
	 * @return DataIntegrationFields.CalloutResponse Response to the callout
	 */
	public static DataIntegrationFields.CalloutResponse executeCalloutOrder(List<String> orderIdList) {
		if (orderIdList.isEmpty()) return new DataIntegrationFields.CalloutResponse('Lista de Order Id Vazia!');

		List<Order> sendOrderList;
		DataIntegrationFields.CalloutResponse calloutResponse;
		IntegrationSettings integrationSetting;
		HttpResponse response;
		String payload;
		try {
			integrationSetting = new IntegrationSettings(IntegrationSetting__c.getValues('ExternalOrgPostOrder'));

			sendOrderList = getOrders(orderIdList);
			payload = JSON.serialize(new DataIntegrationFields.RequestList( fillOrderRequestList(sendOrderList) ));

			response = IntegrationUtils.executeCallout(
				integrationSetting.endpoint,
				payload,
				new Map<String,String>(),
				'POST',
				Integer.valueOf(integrationSetting.timeout)
			);

			calloutResponse = fillCalloutResponse(response);
		}
		catch (Exception ex) {
			System.debug('Exception Integration => ' + ex.getMessage());
			return new DataIntegrationFields.CalloutResponse(ex.getMessage() + ' - ' + ex.getStackTraceString());
		}

		try {
			List<String> externalIdList = new List<String>();
			for (Order order : sendOrderList) externalIdList.add(order.ExternalId__c);

			String errorMessage = handlerError(calloutResponse);
			String integrationLogId = IntegrationLog.createLog(
				'Order',
				externalIdList,
				'Outbound',
				response.getBody(),
				payload,
				errorMessage,
				integrationSetting.endpoint,
				response.getStatusCode(),
				calloutResponse.hasError,
				false
			);

			IntegrationLog.createOrderLogAssociation(sendOrderList, integrationLogId);

			updateSObjectWithIntegrationLogId(sendOrderList, integrationLogId, 'OUT');
		}
		catch (Exception ex) {
			System.debug('Exception Integration Log => ' + ex.getMessage() + ' - ' + ex.getStackTraceString());
		}

		System.debug(calloutResponse);

		return calloutResponse;
	}


	/**
	 * Query the Orders from a list of ids
	 * @param orderIdList List of order ids
	 * @return List<Order> List of retrieved orders
	 */
	public static List<Order> getOrders(List<String> orderIdList) {
		return [
			SELECT Id, ExternalId__c, Account.ExternalId__c, AccountAddress__r.Code__c, CentroDistribuicao__r.Code__c, 
				DataEntrega__c, Observacao__c, EffectiveDate, Pricebook2.ExternalId__c, Status, TipoFrete__c, CondicaoPagamento__r.Codigo__c, 
				(SELECT Id, ExternalId__c, Quantity, UnitPrice, Product2.ExternalId__c, PricebookEntry.ExternalId__c, Order.ExternalId__c FROM OrderItems WHERE DeletedProduct__c = false)
			FROM Order
			WHERE Id IN :orderIdList
		];
	}

	/**
	 * Generates a list of order parameters for the request payload from a list of orders
	 * @param orderList List of Orders to compose the request
	 * @return List<DataIntegrationFields.OrderParameters> List of order parameters
	 */
	public static List<DataIntegrationFields.OrderParameters> fillOrderRequestList(List<Order> orderList) {
		List<DataIntegrationFields.OrderParameters> orderRequestList = new List<DataIntegrationFields.OrderParameters>();

		for (Order order : orderList) {
			orderRequestList.add(new DataIntegrationFields.OrderParameters(order));
		}

		return orderRequestList;
	}

	/**
	 * Get a callout response object from a HttpResponse
	 * @param response HttpResponse from a callout
	 * @return DataIntegrationFields.CalloutResponse Callout response
	 */
	public static DataIntegrationFields.CalloutResponse fillCalloutResponse(HttpResponse response) {
		try {
			if (response.getStatusCode() != 200 && response.getStatusCode() != 201) {
				throw new CustomException('Request Failled');
			}

			Boolean hasError = false;
			List<DataIntegrationFields.ResponseParametersWrapper> responseParameters =
			(List<DataIntegrationFields.ResponseParametersWrapper>)JSON.deserialize(
				response.getBody(), List<DataIntegrationFields.ResponseParametersWrapper>.class
			);

			for (DataIntegrationFields.ResponseParametersWrapper responseParameter : responseParameters) {
				if (responseParameter.hasError) hasError = true;
			}

			return new DataIntegrationFields.CalloutResponse(responseParameters, hasError);
		}
		catch (Exception ex) {
			return new DataIntegrationFields.CalloutResponse(
				'Exception ' + response.getStatus() + '. ' + ex.getMessage() + '. \n' + response.getBody()
			);
		}
	}

	public static String handlerError(DataIntegrationFields.CalloutResponse calloutResponse) {
		if (!calloutResponse.hasError) return '';

		String errorMessage = '';

		if (calloutResponse.parsedResponses != null) {
			for (DataIntegrationFields.ResponseParametersWrapper response : calloutResponse.parsedResponses) {
				if (response.hasError) {
					errorMessage += (response.externalId != null ? response.externalId + ' => ' : '') + response.errorMessage + '\n';
				}

				if (response.items != null) {
					for (DataIntegrationFields.ResponseParametersWrapper item : response.items) {
						if (item.hasError) {
							errorMessage += (item.externalId != null ? item.externalId + ' => ' : '') + item.errorMessage + '\n';
						}
					}
				}
			}
		}
		else errorMessage = calloutResponse.errorMessage;

		return errorMessage;
	}

	public static void callErrorTreatment() {
		System.debug('callErrorTreatment');
	}
	public static void callSuccessTreatment() {
		System.debug('callSuccessTreatment');
	}

	public static void updateSObjectWithIntegrationLogId(List<SObject> sobjectList, String integrationLogId, String integrationType) {
		if (sobjectList.isEmpty()) return;

		List<SObject> sobjectUpdateList = new List<SObject>();
		String sobjectName = sobjectList[0].getSObjectType().getDescribe().getName();

		String query = 'SELECT Id, IntegrationLogInbound__c, IntegrationLogOutbound__c FROM ' + sobjectName + ' WHERE Id IN: sobjectList';

		for (SObject sobj : Database.query(query)) {
			if (integrationType == 'IN') sobj.put('IntegrationLogInbound__c', integrationLogId);
			else sobj.put('IntegrationLogOutbound__c', integrationLogId);

			sobjectUpdateList.add(sobj);
		}

		if (!sobjectUpdateList.isEmpty()) update sobjectUpdateList;
	}

	public static void updateIntegrationSetting(IntegrationSettings integrationSetting) {
		IntegrationSetting__c updateIntegrationSetting = new IntegrationSetting__c(
			Id = integrationSetting.id,
			AccessToken__c = integrationSetting.accessToken,
			LastAccessTokenTime__c = integrationSetting.lastAccessTokenTime
		);

		update updateIntegrationSetting;
	}

	public class CustomException extends Exception {}

	public class AccessTokenLog {
		public String response = '';
		public String payload = '';
		public String endpoint = '';
		public Integer statusCode = 400;

		public AccessTokenLog() {}
	}

	public class IntegrationSettings {
		public String id;

		public Decimal lastAccessTokenTime;
		public Decimal accessTokenTime;
		public Decimal timeout;

		public String endpointAccessToken;
		public String accessToken;

		public String endpoint;
		public String clientId;
		public String clientSecret;
		public String user;
		public String password;
		public String method;

		public Boolean hasUpdateAccessToken;

		public IntegrationSettings(IntegrationSetting__c integrationSetting) {
			this.id = integrationSetting.Id;

			this.lastAccessTokenTime = integrationSetting.LastAccessTokenTime__c;
			this.accessTokenTime = integrationSetting.AccessTokenTime__c;
			this.timeout = integrationSetting.Timeout__c;

			this.endpointAccessToken = integrationSetting.EndpointAccessToken__c;
			this.accessToken = integrationSetting.AccessToken__c;

			this.endpoint = integrationSetting.Endpoint__c;
			this.clientId = integrationSetting.ClientId__c;
			this.clientSecret = integrationSetting.ClientSecret__c;
			this.user = integrationSetting.User__c;
			this.password = integrationSetting.Password__c;
			this.method = integrationSetting.Method__c;

			this.hasUpdateAccessToken = false;
		}
		public void changeAccessTokenTime(Decimal newAccessTokenTime, String accessToken) {
			this.hasUpdateAccessToken = true;
			this.lastAccessTokenTime = newAccessTokenTime;
			this.accessToken = accessToken;
		}
	}

	@InvocableMethod(label='Order Callout' category='Order')
	public static List<Boolean> invocableExecuteCalloutOrder(List<String> orderIdList) {
		System.debug('Execução do Invocable');
		
		return new List<Boolean>{executeCalloutOrder(orderIdList).hasError};
	}

}