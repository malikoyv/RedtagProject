### Salesforce Quote PDF Generation and Email Functionality Documentation

This documentation covers the functionality implemented for sending a PDF version of a Quote through email. The system allows the Opportunity Manager to send an email with a PDF attachment containing important information from the Quote, such as the Quote, Quote Line Items, Account, and Contact details. This functionality has been implemented using **Screen Flow**, **Apex Classes**, and a **Visualforce Page**.

---

### Overview

1. **Requirement**:
   - Send an email with a PDF attachment that contains important details of the Quote.
   - The email recipient should be selectable from all available contacts in the organization, with the Quote Contact as the default recipient.
   - Quote Line Items should be represented in a table format with product images.
   
2. **Solution**:
   - A **Screen Flow** launched from a button on the Quote Layout.
   - The flow allows users to select a recipient from a list of all Contacts.
   - An Apex class generates the PDF and sends the email with the PDF attached.
   - Visualforce is used to format the Quote data and Quote Line Items into a PDF.

---

### **Flow Structure**

1. **Start (Screen Flow)**: 
   The flow is initiated from the Quote layout by the Opportunity Manager using a button.

2. **Get All Contacts (Get Records)**: 
   The flow retrieves all Contact records from the organization to display in the next step.

3. **Choose a Recipient (Screen)**: 
   The flow presents the user with a screen to select a recipient for the email. The default recipient is set to the Quote Contact.

4. **Set Recipient's Email (Assignment)**: 
   The selected recipient's email is assigned to a variable to be used in the email generation process.

5. **Apex PDF Generator (Apex Action)**: 
   The flow triggers an Apex action to generate the PDF and send the email.

6. **End**: 
   The flow concludes once the email is successfully sent.

---

### **Apex Classes**

#### **1. `QuotePDFController` (Apex Class)**

This class manages the email process with PDF attachment and provides the method to be invoked by the Flow.

- **Methods**:
  - **`sendEmailWithPDF(List<EmailParams> paramsList)`**: This method is an Invocable Method that receives a list of `EmailParams`, which contains the email address and the Quote ID. It delegates the actual email sending to the `EmailService` class.
  
  - **Nested Class: `EmailParams`**:
    - **`emailAddress`**: Stores the email address of the recipient.
    - **`quoteId`**: Stores the ID of the Quote to be used for generating the PDF.

#### **2. `EmailService` (Apex Class)**

This class contains the logic for sending emails, both for deleted opportunities and for sending Quote emails with PDF attachments.

- **Methods**:
  - **`sendEmail(List<Opportunity> deletedOpps, String templateName)`**: Sends emails using a stored email template when an Opportunity is deleted. This method is unrelated to the Quote functionality but is included in the class for general email service.
  
  - **`sendQuoteEmailWithPDF(List<QuotePDFController.EmailParams> paramsList)`**: 
    - Loops through the `EmailParams` list to process each Quote.
    - Retrieves the Quote details using the `quoteId`.
    - Constructs the email message with the recipient’s email address, subject, and body.
    - Generates a PDF using the `generatePDF` method and attaches it to the email.
    - Sends the email using `Messaging.sendEmail`.
  
  - **Private Helper Method: `generatePDF(Id quoteId)`**:
    - Generates a PDF of the Quote by invoking the Visualforce page (`QuotePDF`).
    - Converts the page content into a Blob and returns it for attachment to the email.

---

### **Visualforce Page: `QuotePDF`**

This Visualforce page renders as a PDF and displays the details of the Quote, including Quote Line Items in a table format with product images.

- **Main Features**:
  - Displays the Quote Name, Account Name, and Quote Contact in a table.
  - Renders Quote Line Items in a table format with the following columns:
    - Product Image (from `Product2.Product_Image__c`)
    - Product Name
    - Quantity
    - Unit Price
    - Total Price
  
  - The **customer policy** section provides important terms and conditions regarding the Quote, including:
    - Pricing and Validity
    - Payment Terms
    - Delivery Terms
    - Warranty and Returns
    - Cancellations and Modifications
    - Liability Limitations
    - Customer Responsibility
  
  - The **signature section** includes placeholders for the Quote Contact’s name and signature date.
  
- **Styling**:
  - The page uses inline CSS to style the tables and text.
  - The `page-break-before` CSS rule ensures the policy section starts on a new page.

---

### **Flow Execution and Email Sending Process**

1. The Opportunity Manager initiates the flow via a button on the Quote page.
2. The flow presents the manager with a screen to choose the email recipient from a list of all Contacts.
3. The selected email address and Quote ID are passed to the Apex class via the flow.
4. The Apex class retrieves the Quote data and generates a PDF using the Visualforce page.
5. The PDF is attached to an email, and the email is sent to the selected recipient.

---

### **Key Benefits and Features**

- **Dynamic Recipient Selection**: 
   - Users can select a recipient from a list of all contacts in the organization, with the default recipient being the Quote Contact.

- **Formatted PDF Generation**: 
   - The PDF is automatically generated from the Quote data, and all Quote Line Items are listed in a structured table with product images.

- **Automated Email**: 
   - The entire process of generating the PDF and sending the email is automated through the flow, reducing manual work for the Opportunity Manager.

---

### **Future Enhancements**

- **Error Handling**: 
   - Currently, error handling is done using debug statements. Consider implementing user-friendly error messages or notifications within the flow in case of email sending failures.

- **Custom Email Templates**: 
   - The email body is currently a plain text message. A future improvement could involve using a custom email template for a more professional-looking email.

- **Additional Customization for PDF**: 
   - The Visualforce page can be further enhanced with additional styling or dynamic content to match specific customer needs.

---

This solution provides a streamlined process for sending Quote PDFs with detailed Quote information and product line items. The use of Salesforce Flow and Apex ensures the process is efficient and easy to maintain.

