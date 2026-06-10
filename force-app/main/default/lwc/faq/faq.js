import { LightningElement } from 'lwc';

export default class Faq extends LightningElement {
    faqs = [
        {
            id: 1,
            question: "Quem proclamou a independência?",
            answer: "<ul><li>Pedro Álvares Cabral</li></ul>"
        }
    ]
}