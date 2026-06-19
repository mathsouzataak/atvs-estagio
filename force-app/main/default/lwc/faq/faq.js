import { LightningElement, wire, } from 'lwc';
import { gql, graphql } from "lightning/graphql";

export default class Faq extends LightningElement {
    results;
    errors;

    after = null;
    pageNumber = 1;

    afterBuffer;
    cursorStack = [];
    hasNextPage;
    hasPreviousPage;
    totalCount = 0;


    searchString = '%';

    @wire(graphql, {
        query: gql`
            query searchFaq($searchString: TextArea, $after: String) {
                uiapi {
                    query {
                        FAQ__c(
                            first: 10
                            after: $after
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
                            totalCount
                            pageInfo {
                                startCursor
                                endCursor
                                hasNextPage
                                hasPreviousPage
                            }
                        }
                    }
                }
            }
        `,
        variables: '$variables'
    })
    getRecords({ data, errors }) {
        if (data) {
            const faqData = data.uiapi.query.FAQ__c;
            this.results = faqData.edges.map((edge) => edge.node);
            this.afterBuffer = faqData.pageInfo.endCursor;
            this.hasNextPage = faqData.pageInfo.hasNextPage;
            this.hasPreviousPage = faqData.pageInfo.hasPreviousPage;
            this.totalCount = faqData.totalCount;
            console.log('Results:', this.results);
        }
        this.errors = errors;
        if (errors) {
            console.log('Errors:', errors[0].message);
        }
    }

    get variables() {
        return {
            searchString: this.searchString,
            after: this.after || null,
        };
    }

    get currentPageNumber() {
        return this.totalCount === 0 ? 0 : this.pageNumber;
    }

    get isFirstPage() {
        return !this.hasPreviousPage;
    }

    get isLastPage() {
        return !this.hasNextPage;
    }

    get totalPages() {
        return Math.ceil(this.totalCount / 10);
    }



    handleSearch(event) {
        setTimeout(() => {
            this.searchString = '%' + event.detail.value.trim() + '%';
            console.log(this.searchString);
            console.log(this.variables);
            this.after = null;
            this.cursorStack = []
            this.pageNumber = 1;
        }, 1000);
    }

    handleNext() {
        if (this.hasNextPage) {
            this.cursorStack.push(this.after);
            this.after = this.afterBuffer;
            this.pageNumber++;
        }
    }

    handlePrevious() {
        if (this.hasPreviousPage) {
            this.after = this.cursorStack.pop();
            this.pageNumber--;
        }
    }
}