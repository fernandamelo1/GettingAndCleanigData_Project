Getting and Cleaning Data.
--------------------------

This is the Assessment Project for the Course Getting and Cleaning Data.


Description of the script run_analysis.R
----------------------------------------

Instructions for project
------------------------

> The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

> One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 

> http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

> Here are the data for the project: 

> https://d396qusza40orc.cloudataframeront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

> You should create one R script called run_analysis.R that does the following. 
1. Merges the training and the test sets to create one data set. 
2. Extracts only the measurements on the mean and standard deviation for each measurement.  
3. Uses descriptive activity names to name the activities in the data set 
4. Appropriately labels the data set with descriptive variable names.  
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


Download Data Set
------------------
We download the dataset from the url given above. We will extract with the library unzip

```{r}
path<-getwd()
url <- "https://d396qusza40orc.cloudataframeront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
f <- 'ProjectData.zip'
if (!file.exists(path)) {dir.create(path)}
download.file(url, file.path(path, f))
unzip("Projectdata.zip")
```

Requirements
------------
```
library(plyr) 

library(dplyr)
```

Directory of Dataset
--------------------
Create a variable called `path_dataset` where are our data.

```{r}
path_dataset <- file.path(path, "UCI HAR Dataset")
```


1. Merge the training and test sets to create one data set 
------------------------------------------------------------
Let's read the train and test datasets and merge using `rbind`:

```{r}
x_train <- read.table(file.path(path_dataset,"train","X_train.txt"))
y_train <- read.table(file.path(path_dataset,"train","y_train.txt"))
subject_train <- read.table(file.path(path_dataset,"train","subject_train.txt"))


x_test <- read.table(file.path(path_dataset,"test","X_test.txt"))
y_test <- read.table(file.path(path_dataset,"test","y_test.txt"))
subject_test <- read.table(file.path(path_dataset,"test","subject_test.txt"))
```{r}
 

create 'x' data set
```{r}
x_data <- rbind(x_train, x_test) 
```{r}

create 'y' data set 
```{r}
y_data <- rbind(y_train, y_test) 
```{r}

create 'subject' data set 
```{r}
subject_data <- rbind(subject_train, subject_test) 
```{r}

  
2. Extract only the measurements on the mean and standard deviation for each measurement 
-----------------------------------------------------------------------------------------
Read features.txt who contain all the features (measurements)

```{r}
features <- read.table(file.path(path_dataset,"features.txt")) 
```{r}

Get only columns with mean() or std() in their names 
 ```{r} 
 mean_and_std_features <- grep("-(mean|std)\\(\\)", features[, 2]) 
```{r}

 Subset the desired columns 
 ```{r} 
 x_data <- x_data[, mean_and_std_features] 
```{r}

 correct the column names 
 ```{r}
 names(x_data) <- features[mean_and_std_features, 2] 
```{r}


3.Use descriptive activity names to name the activities in the data set  
-------------------------------------------------------------------------

```{r}
activities <- read.table(file.path(path_dataset,"activity_labels.txt")) 
```{r}

Update values with correct activity names
```{r}
y_data[, 1] <- activities[y_data[, 1], 2] 
```{r}

Correct column name
```{r}
names(y_data) <- "activity" 
```{r}


4. Appropriately label the data set with descriptive variable names. 
---------------------------------------------------------------------

Correct column name 
```{r}
names(subject_data) <- "subject" 
```{r}

Bind all the data in a single data set 
```{r}
all_data <- cbind(x_data, y_data, subject_data) 
```{r}




5.Create tidy data set with the average of each variable for each activity and each subject. (using dataset in step 4)
-----------------------------------------------------------------------------------------------------------------------

66 <- 68 columns but exclude last two (activity & subject)
 ```{r}
averages_data <- ddply(all_data, .(subject, activity), function(x) colMeans(x[, 1:66])) 
```{r}

Create the tidy data
--------------------

```{r}
write.table(averages_data, "tidy_data.txt", row.name=FALSE) 
```{r}




