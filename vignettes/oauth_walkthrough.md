---
title: "Google OAuth App Walkthrough"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteEngine{knitr::knitr}
  %\VignetteIndexEntry{Google OAuth App Walkthrough}
  %\VignetteEncoding{UTF-8}
---



## This is a walkthrough on how to set up your own Google OAuth App for Submission Collection with Gmail and Google Drive.

### 1. Navigate to [console.cloud.google.com](https://console.cloud.google.com) and login to your cloud console.

Note: It may not be necessary to login if you already logged in to your google account.

<img src="images/oauth_walkthrough_images/oauth_1.png" alt="plot of chunk unnamed-chunk-1" width="50%" />

### 2. Click the dropdown that displays the name of your project or "Select a Project". This takes you to the modal where you will create the project.

<img src="images/oauth_walkthrough_images/oauth_2.png" alt="plot of chunk unnamed-chunk-2" width="50%" />

### 3. Click "New Project" on the top right of the modal. It should tell you there is a certain number of projects remaining.

<img src="images/oauth_walkthrough_images/oauth_3.png" alt="plot of chunk unnamed-chunk-3" width="50%" />

### 4. Name and Create your project.

We used the name "Submission Collector", but you can use whatever name you want.

Don't worry about the Organization Tab.

<img src="images/oauth_walkthrough_images/oauth_4.png" alt="plot of chunk unnamed-chunk-4" width="50%" />

### 5. Select the project.

You may use the project dropdown menu from Step 2 to navigate to your new project,

Or click "Select the project" to navigate to your new project.

<img src="images/oauth_walkthrough_images/oauth_5.png" alt="plot of chunk unnamed-chunk-5" width="50%" />

<img src="images/oauth_walkthrough_images/oauth_24.png" alt="plot of chunk unnamed-chunk-6" width="50%" />

### 6. Click the triple dash side bar and navigate to "Marketplace"

Note: No payment is needed for this walkthrough or for this project.

<img src="images/oauth_walkthrough_images/oauth_6.png" alt="plot of chunk unnamed-chunk-7" width="50%" />

### 7. Search for and Click "Enable" for Gmail API

Search for "Gmail API" in the searchbar.

<img src="images/oauth_walkthrough_images/oauth_7.png" alt="plot of chunk unnamed-chunk-8" width="50%" />

<img src="images/oauth_walkthrough_images/oauth_8.png" alt="plot of chunk unnamed-chunk-9" width="50%" />

Click "Enable" to enable the Gmail API in your project.

<img src="images/oauth_walkthrough_images/oauth_9.png" alt="plot of chunk unnamed-chunk-10" width="50%" />

### 8. Do the same for Google Drive API

Search for "Google Drive API" in the searchbar.

<img src="images/oauth_walkthrough_images/oauth_10.png" alt="plot of chunk unnamed-chunk-11" width="50%" />

<img src="images/oauth_walkthrough_images/oauth_11.png" alt="plot of chunk unnamed-chunk-12" width="50%" />

Click "Enable" to enable the Google Drive API in your project.

<img src="images/oauth_walkthrough_images/oauth_12.png" alt="plot of chunk unnamed-chunk-13" width="50%" />

### 9. Use the triple dash side bar to navigate to "APIs and services" > "Credentials"

<img src="images/oauth_walkthrough_images/oauth_13.png" alt="plot of chunk unnamed-chunk-14" width="50%" />

### 10. Click on "Configure Consent Screen"

<img src="images/oauth_walkthrough_images/oauth_14.png" alt="plot of chunk unnamed-chunk-15" width="50%" />

### 11. For the first question, select "External" and click "Create"

<img src="images/oauth_walkthrough_images/oauth_16.png" alt="plot of chunk unnamed-chunk-16" width="50%" />

### 12. Fill out and save the form for the consent screen. You have to fill in all the fields with a red * beside it.

For the "App Name", we used "personal submission collector" but you can use any name you want.

For the "User Support Email", select your email from the dropdown menu.

For the "Developer contact information", fill in your own email.

Click "Select and Continue"

<img src="images/oauth_walkthrough_images/oauth_23.png" alt="plot of chunk unnamed-chunk-17" width="50%" />

For all the next steps, skip everything and just click "Save and Continue".

### 13. Navigate back to the "Credentials" Screen

<img src="images/oauth_walkthrough_images/oauth_13.png" alt="plot of chunk unnamed-chunk-18" width="50%" />

### 14. Click "+ Create Credentials" and in the dropdown, select "OAuth client ID"

<img src="images/oauth_walkthrough_images/oauth_17.png" alt="plot of chunk unnamed-chunk-19" width="50%" />

### 15. Fill out the form as below, you can change the name based on your liking

For the "Redirect URI", add "http://localhost:1410/"

Then click "Create".

<img src="images/oauth_walkthrough_images/oauth_18.png" alt="plot of chunk unnamed-chunk-20" width="50%" />


### 16. VERY IMPORTANT: After creating your credentials, a modal will pop up with your client id (key) and client secret. Store them somewhere safe because this will be used for the submission collection script.

<img src="images/oauth_walkthrough_images/oauth_19.png" alt="plot of chunk unnamed-chunk-21" width="50%" />

### 17. After saving your key and secret, navigate to the "OAuth consent screen".

<img src="images/oauth_walkthrough_images/oauth_20.png" alt="plot of chunk unnamed-chunk-22" width="50%" />

### 18. Scroll down to "Test users", click "+ Add Users"

<img src="images/oauth_walkthrough_images/oauth_21.png" alt="plot of chunk unnamed-chunk-23" width="50%" />

### 19. Add the email you are using to receive submission with and "Save".

<img src="images/oauth_walkthrough_images/oauth_22.png" alt="plot of chunk unnamed-chunk-24" width="50%" />


## YOU'RE DONE!




