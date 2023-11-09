import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getFieldsData from '@salesforce/apex/AccountFormController.getFieldsData';
import saveData from '@salesforce/apex/AccountFormController.saveData';

export default class AccountForm extends LightningElement {
    @api AccountFieldSchema = [];
    @api ContactFieldSchema = [];
    connectedCallback() {
        getFieldsData()
            .then(result => {
                if (result) {
                    console.log('Field Structure ==>' + JSON.stringify(result));
                    this.AccountFieldSchema = result;
                }
            })
            .catch(error => {
                console.log(error);
            });
    }
    ProcessData() {
        const allValid = [
            ...this.template.querySelectorAll("lightning-input"),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            console.log('Field Schema ==> from Process Data' + JSON.stringify(this.AccountFieldSchema));
            var Accdata = JSON.stringify(this.AccountFieldSchema);
            saveData({ accountData: Accdata })
                .then(result => {
                    if (result) {
                        console.log('Accdata' + Accdata);
                        console.log('Field Structure ==>' + JSON.stringify(result));
                        const event = new ShowToastEvent({
                            title: 'Success!',
                            message: 'The Account was successful Created.',
                            variant: 'success',
                        });
                        this.dispatchEvent(event);
                    }
                    for(var i=0;i<this.AccountFieldSchema.length;i++){

                        this.AccountFieldSchema[i]['fieldData'] ='';
                    }
                })
                .catch(error => {
                    console.log(error);
                });
        }
        else {
            const event = new ShowToastEvent({
                title: 'error!',
                message: 'The operation was fail.',
                variant: 'error',
            });
            this.dispatchEvent(event);
        }
    }
    getFieldInput(event) {
        const fieldId = event.target.dataset.id;
        const value = event.target.value;
        for (var i = 0; i < this.AccountFieldSchema.length; i++) {
            if (this.AccountFieldSchema[i].hasOwnProperty('FieldApiName')) {
                if (this.AccountFieldSchema[i]['FieldApiName'] == fieldId) {
                    this.AccountFieldSchema[i]['fieldData'] = value;
                }
            }
        }
    }
}