import { LightningElement } from 'lwc';

export default class OrderInput extends LightningElement {
    accountId = "";


    handleAccountChange(event) {
        this.accountId = event.detail.recordId;
        console.log(this.accountId);
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

}