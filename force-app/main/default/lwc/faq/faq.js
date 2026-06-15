import { LightningElement, wire } from 'lwc';
import { gql, graphql } from "lightning/graphql";

export default class Faq extends LightningElement {
    results;
    errors;

    searchString = '%';

    @wire(graphql, {
        query: gql`
            query searchFaq($searchString: TextArea) {
                uiapi {
                    query {
                        FAQ__c(
                            where: { 
                                Question__c: { like: $searchString }
                            }        
                        ) {
                            edges {
                                node {
                                    Id
                                    Question__c {
                                        value
                                    }
                                    Answer__c {
                                        value
                                    }
                                }
                            }
                        }
                    }
                }
            }
        `,
        variables: '$variables'
    })
    getRecords({data, errors}) {
        if (data) {
            this.results = data.uiapi.query.FAQ__c.edges.map((edge) => edge.node);
            console.log('Results:');
            console.log(this.results);
        }
        this.errors = errors
        console.log('Errors:');
        console.log(this.errors);
    }

    get variables() {
        return {
            searchString: this.searchString,
        };
    }


    handleSearch(event) {
        setTimeout(() => {
            this.searchString = '%' + event.detail.value.trim() + '%';
            console.log(this.searchString);
            console.log(this.variables);
        }, 1000);
    }
}