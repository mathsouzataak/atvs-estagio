import { LightningElement, wire } from 'lwc';
import getPaymentConditionList from '@salesforce/apex/OrderController.getPaymentConditionList';

export default class OrderInput extends LightningElement {
    
    accountId = "";
    paymentConditionId;
    addressId;
    observations;

    paymentConditionOptions = [];
    
    
    
    handleAccountChange(event) {
        this.accountId = event.detail.recordId;
        console.log(this.accountId);
    }

    handlePaymentSelected(event) {
        this.paymentConditionId = event.target.value;
    } 

    handleAddressChange(event) {
        this.addressId = event.detail.recordId;
    }

    handleObservations(event) {
        this.observations = event.target.value
    }


    
    get addressFilter() {
        return {
            criteria: [
                { 
                    fieldPath: "Account__c",
                    operator: "eq",
                    value: this.accountId
                }
            ]
        };
    }


    
    @wire(getPaymentConditionList)
    wiredPaymentConditions({error, data}) {
        if (data) {
            console.log('Combobox data:')
            console.log(data);
            this.paymentConditionOptions = data.map((record) => ({
                value: record.Id,
                label: record.Name
            }));
        } 
    
        console.log(error);
    }

}