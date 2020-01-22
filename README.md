# Javascript Webview iOS challenge

I organized the project into 5 folders: Helpers, Views, Models, Controllers, and Services.  I will explain what I have in each of the folders.

Helpers
- I wrote an extension for the UITableView to update a specific row in the tableview.  This is useful when updating a operation corresponding to the message received from the message handler in the javascript code.  I wanted to avoid updating the entire tableview with reloadData() since it would take unnessary processing power.

Views
- The WebViewHandler handles all interactions and logic related to the webview which occupies the top half of the screen.  This would split out any logic related to the WKWebview from the Main controller and avoid the massive view controller.  
- I decided to use a xib file for the OperationTableViewCell because if working on a team of developers it would help mitigate chances of merge conflicts.  The OperationTableViewCell shows informationi related to a specific operation that was started by the user.

Models
- The MessageData model reflects the message data structure that would be received from the message handler in the javascript code.

Controllers
- MainVC is the liaison between the views(Webview, Tableview of operations), model, and other business logic related to operations.

Services
- Most of the business logic related to operations is laid out in OperationService.  This is where you will find the logic for generating random strings and parsing out MessageData and prepping it for the Main View Controller.  It also keeps track of what's in the operation queue.

