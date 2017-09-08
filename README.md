
![](example_shiny_app.png)

See it in action (quickly run on your computer):
------------------------------------------------

    shiny::runGitHub("shinyviz", "riinuots")

The packages you'll have to have installed:

    library(shiny)
    library(shinythemes)

    library(ggplot2)
    library(tidyr)
    library(dplyr)
    library(forcats)
    library(magrittr)
    library(scales)

Most of these come with `install.packages("tidyverse")` (<http://tidyverse.org/>).

Apply it on your dataset
------------------------

Most of the code in this app very very generecally written so it can be (and has already been) applied to different datasets.

-   Create a new empty RStudio project.
-   Download the server.R, ui.R, and formatted\_varnames\_forUI.csv files, put them in your project.
-   Open the scripts server.R and ui.R in the editor.
-   Click on Run App to make sure it works (this will use the diamonds example dataset).
-   Upload your data into the project.
-   List the categorical variables you would like to be included in the app in formatted\_varnames\_forUI.csv. Keep the first two lines as they are.
-   Run App: check that the dropdown menus now include your variables. The app's Plot tab will now display an Error. This is because it is still using the diamonds dataset, but looking for your variables.
-   Go to ui.R and edit the three linea starting with `default_` to set the variables you want to be shown on app startup. For explanatory1 or exmplanatory2 you can use our dummy variable called "aaa.onepanel" to just plot everything together and leave the splitting to the user.
-   Go to server.R and replace the top bit where diamonds is called with your dataset. You can delete the lines that cut continuous variables into categories as those are specific to the diamonds dataset. Make sure to keep `alldata$aaa.onepanel = "ALL"`.
-   When you run the app now, you should get an error or "match requires vector arguments", that's because we haven't set up the Subetting functionality (and it is still trying to subset for diamond cuts).
-   To be continued...
