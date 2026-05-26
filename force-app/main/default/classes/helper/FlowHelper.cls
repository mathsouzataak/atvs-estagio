public with sharing class FlowHelper {
    public static Boolean isFlowActive(String flowApiName) {
        List<FlowDefinitionView> flows = [
            SELECT Id, ApiName, ActiveVersionId, LatestVersionId, IsActive
            FROM FlowDefinitionView
            WHERE ApiName = :flowApiName
            LIMIT 1
        ];
        
        return !flows.isEmpty() && flows[0].IsActive;
    }
}