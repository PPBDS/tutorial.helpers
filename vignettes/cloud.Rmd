---
title: "Using Tutorials with Posit Cloud"
author: David Kane
output: rmarkdown::html_vignette
vignette: >
  %\VignetteEngine{knitr::knitr}
  %\VignetteIndexEntry{Using Tutorials with Posit Cloud}
  %\VignetteEncoding{UTF-8}
---

[Posit Cloud](https://posit.cloud/) is the most common cloud service to use when working with [RStudio](https://posit.co/download/rstudio-desktop/), not least because [Posit](https://posit.co/) is also the company behind RStudio. Using Posit Cloud with tutorials created with the [**tutorial.helpers**](https://ppbds.github.io/tutorial.helpers/) package is tricky. The purpose of this vignette is to explain the process.

First, when signing up, choose the "[Cloud Free](https://posit.cloud/plans)" plan. At least for the first 20 hours or so of use, do not give Posit your credit card number. If Posit Cloud is working well for you, and you use more than the 25 hours per month allowed (currently) by the Cloud Free plan, then you might pay and upgrade. There are also sometimes discounts for students/teachers. I

Second, follow the Posit Cloud [instructions](https://posit.cloud/learn/guide) to login, an action which should automatically place you in your Workspace. Once there, set up a new RStudio Project. This is all fairly simple and just involves clicking some buttons. Once you have a new Project, you should be able to follow the [standard instructions](https://ppbds.github.io/tutorial.helpers/) for working with the **tutorial.helpers** package. That is, running `install.packages("tutorial.helpers")` should work as the first R command you issue in the Console.

Third, go to the Tutorial pane in the upper right and scroll to the bottom. Tutorials are listed in the alphabetical order of the packages in which they reside, so the "Getting Started" tutorial is usually the bottom tutorial. Press the "Start Tutorial" button. You may be asked to install the **tidyverse** package. If so, please agree.

Fourth, the "Getting Started" tutorial will be created, with messages shown in the "Background Jobs" tab. After a few moment, the tutorial will be complete, also appearing in the Tutorial pane. You may work on it either in the Tutorial pane or, by clicking the "Show in new window" button (located between the "Return to home" and "Stop tutorial" buttons), in its own window. I recommend leaving it in the Tutorial pane. Note that you can adjust the different window sizes to give the Tutorial pane more room.

Fifth, once you complete the tutorial, you can download your answers. Note that, in Posit Cloud, just pressing a download button, for any format, will probably not work. Instead, you will need to follow the instructions you see and use an alternative or secondary click. This is either a two finger or `Ctrl + click` on the Mac or a right click on Windows. This action will bring up a menu, one choice of which is "Save link as ..." Choose this option and dowload the file, probably to your Downloads file. Except the default name for the file. An appropriate suffix will be added automatically.



