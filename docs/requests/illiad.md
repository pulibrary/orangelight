### ILLiad requests integration

#### Sequence of a request

An ILLiad request goes through the following steps, as illustrated by the diagram below:

1. Patron presses the "Request" button
1. Catalog renders a request form with the relevant metadata in hidden fields.
1. Patron submits the form.
1. Catalog creates a transaction via the ILLiad API.
1. If transaction is created successfully:
    1. ILLiad API returns the transaction ID.
    1. Catalog uses the transaction ID to add a note via the ILLiad API.
1. If transaction is not created successfully:
    1. ILLiad API returns a blank transaction
    1. Catalog reports "Invalid Interlibrary Loan Request" error to patron
### ILLiad Request Mermaid
```mermaid
sequenceDiagram
    title Placing an ILLiad request
    actor patron as Patron
    participant Catalog
    participant illiad as ILLiad API
    patron->>Catalog: Press "Request" button
    Catalog->>patron: Renders a requests form<br> with the relevant metadata<br> in hidden fields
    patron->>Catalog: Submit the form
    Catalog->>illiad: Create a transaction
    alt Transaction is created successfully
        illiad->>Catalog: Return the transaction id
        Catalog->>illiad: Add note to the transaction
    end
    alt Transaction is not created successfully
        illiad->>Catalog: Return a blank transaction
        Catalog->>patron: Report "Invalid Interlibrary Loan Request" error 
    end
```
