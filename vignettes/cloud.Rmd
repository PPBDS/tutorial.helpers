---
title: "Using Tutorials with Posit Cloud"
author: David Kane
output: rmarkdown::html_vignette
vignette: >
  %\VignetteEngine{knitr::knitr}
  %\VignetteIndexEntry{Using Tutorials with Posit Cloud}
  %\VignetteEncoding{UTF-8}
---

[Posit Cloud](https://posit.cloud/) is the most common cloud service to use when working with [RStudio](https://posit.co/download/rstudio-desktop/), not least because [Posit](https://posit.co/) is also the company behind RStudio. Using Posit Cloud with tutorials created with the [**tutorial.helpers**](https://ppbds.github.io/tutorial.helpers/) package is sometimes tricky. The purpose of this vignette is to explain the process.

First, when signing up, choose the "[Cloud Free](https://posit.cloud/plans)" plan. At least for the first 20 hours or so of use, do not give Posit your credit card number. If Posit Cloud is working well for you, and you use more than the 25 hours per month allowed (currently) by the Cloud Free plan, then you might pay and upgrade. There are also sometimes discounts for students/teachers. I

Second, follow the Posit Cloud [instructions](https://posit.cloud/learn/guide) to login, an action which should automatically place you in your Workspace. Once there, set up a new RStudio Project. This is all fairly simple and just involves clicking some buttons. Once you have a new Project, you should be able to follow the [standard instructions](https://ppbds.github.io/tutorial.helpers/) for working with the **tutorial.helpers** package. That is, running `install.packages("tutorial.helpers")` should work as the first R command you issue in the Console.

Third, go to the Tutorial tab in the upper right corner and scroll to the bottom. Tutorials are listed in the alphabetical order of the packages in which they reside, so the "Getting Started with Tutorials" tutorial is usually the bottom tutorial. Press the "Start Tutorial" button. 

Fourth, the "Getting Started with Tutorials" tutorial will be created, with messages shown in the "Background Jobs" tab. After a few moment, the tutorial will be complete, also appearing in the Tutorial pane. You may work on it either in the Tutorial pane or, by clicking the "Show in new window" button --- located between the "Return to home" and "Stop tutorial" buttons --- in its own window. I recommend leaving it in the Tutorial tab. Note that you can adjust the different window sizes to give the Tutorial tab more room.

Fifth, once you complete the tutorial, you can download your answers. Note that, in Posit Cloud, just pressing a download button, for any format, will probably not work. Instead, you will need to follow the instructions you see and use an alternative or secondary click. This is either a two finger click (or `Ctrl + click`) on the Mac or a right click on Windows. This action will bring up a menu, one choice of which is "Save link as ..." Choose this option and download the file, probably to your Downloads folder. Accept the default name for the file. An appropriate suffix will be added automatically.

**Warning**: Posit Cloud shuts down unused sessions aggressively. If you stop working on your tutorial, it will be closed and "greyed out." To restart it, you need to press the "Return to home" button --- the little house symbol with the red roof --- and then restart your tutorial. All your previous answers will be saved so you can just pick up where you left off. 

### Tutorials and RStudio Projects

In most tutorials, you never leave the RStudio Project in which you started the tutorial. 

Some tutorials require you to create a new RStudio Project. Examples from the **r4ds.tutorials** package include "RStudio and code," RStudio and Github," and "Quarto." This works fine on your local computer. On Posit Cloud, things are trickier. You must manually keep track of the different RStudio Projects in which you are working. 

In order to start a new RStudio Project on Posit Cloud, you must go back to your Workspace, click on "New Project" in the upper right, select "New Project from a Git Repository," and then provide the URL for your Git repo. Once you click "OK," you will now have two RStudio Projects in your Workspace.

These two projects are completely separate. They run on separate "containers," i.e., on separate computers with no connection to one another. One might think that this is not a problem. We should be able to just move back-and-forth between the two RStudio Projects, just as we would on a local computer. But that does not work on Posit Cloud because each time you switch away from the tutorial RStudio Project, Posit Cloud closes the tutorial, thereby requiring you to restart it each time you come back. That is very annoying!

The solution is for you to login to Posit Cloud twice, keeping each login in its own tab on your browser. In one login, you are looking at the tutorial RStudio Project, answering questions as you go along. In the other login, you are looking at the second RStudio Project, which is usually connected to a Github repo. This is where you are doing most of your work. But, because these two logins are just two tabs on your browser, it is easy to switch back and forth.

**Warning**: On Posit Cloud (unlike on your local computer) progress on a tutorial is not saved across RStudio Projects That is, if you close the RStudio Project in which you have been working on a tutorial, you will lose all the work you have done on that tutorial.

### RStudio Project Templates

One problem with working with RStudio on Posit Cloud is that each new RStudio Project is "clean," meaning that no packages have been installed and any RStudio settings you may have selected in previous RStudio Projects have disappeared. The best way to solve this is to create a [Project Template](https://posit.cloud/learn/guide#project-templates). The idea behind templates is that you want to start new RStudio Projects with all your favorite packages already installed, all your preferred RStudio preferences already selected, and so on. If you do all these things in your template, then each new RStudio Project you create will start up with all these tasks already accomplished.
