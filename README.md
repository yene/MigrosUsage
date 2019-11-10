#  M-Usage

I needed a solution to quickly check how much data is left on my M-Budget Mobile data plan.

![screenshot](screenshot.png)


## Notes
* It does a log-in into the users profile page and extracts the usage information from HTML, maybe you can use the code for your own app?
* Today Widget uses the Notifications icon.
* Getting the data is a bit slow because it needs about 4 HTTP requests to get the data.
* The login data is shared with the Today Widget, over the Keychain.
