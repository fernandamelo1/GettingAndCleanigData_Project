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

Requirements
------------
We will use `data.table` because it's faster and give us a easy way to work with data.
```{r}
library(data.table)
```

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


Directory of Dataset
--------------------
Create a variable called `path_dataset` where are our data.

```{r}
path_dataset <- file.path(path, "UCI HAR Dataset")
```

1. Merge the training an test to one data set
---------------------------------------------
Let's read the train and test datasets and merge using `rbind`:

- path_dataset/train/**X_train.txt** and path_dataset/test/**X_test.txt** is stored in a variable called **`Data_set`**.
- path_dataset/train/**subject_train.txt** and path_dataset/test/**subject_text.txt** is stored in a variable called **`Data_subject`**
- path_dataset/train/**y_train.txt** and path_dataset/test/**y_train.txt** is stored in a variable called **`Data_label`**

Creating **Data_set**
```{r}
dataframe_train_set<-read.table(file.path(path_dataset,"train","X_train.txt"))
Data_train_set<-data.table(dataframe_train_set)

dataframe_test_set<-read.table(file.path(path_dataset,"test","X_test.txt"))
Data_test_set<-data.table(dataframe_test_set)

Data_set <- rbind(Data_train_set, Data_test_set)
```


Creating **Data_subject** and rename the column to `subject_id` **identifies the subject who performed the activity**
```{r}
dataframe_subject_train<-read.table(file.path(path_dataset,"train","subject_train.txt"))
Data_subject_train<-data.table(dataframe_subject_train)

dataframe_subject_test<-read.table(file.path(path_dataset,"test","subject_test.txt"))
Data_subject_test<-data.table(dataframe_subject_test)

Data_subject <- rbind(Data_subject_train, Data_subject_test)
setnames(Data_subject, names(Data_subject), c("subject_id"))
```

Creating **Data_label** and rename the columns to `activity_id` **identifies the activity id**
```{r}
dataframe_label_train <-read.table(file.path(path_dataset,"train","y_train.txt"))
Data_label_train <-data.table(dataframe_label_train)

dataframe_label_test <-read.table(file.path(path_dataset,"test","y_test.txt"))
Data_label_test <-data.table(dataframe_label_test)

Data_label <- rbind(Data_label_train, Data_label_test)

setnames(Data_label, names(Data_label), c("activity_id"))
```


So we join the column `Data_subject` and  `Data_labels` to the final Data_set.
```{r}
Data_set<-cbind(Data_set,Data_subject, Data_label)
```

2. Extracts only the measurements on the mean and standard deviation for each measurement
-----------------------------------------------------------------------------------------
Read features.txt who contain all the features (measurements)

```{r}
dataframe_features <- read.table(file.path(path_dataset,"features.txt"))
Data_features<-data.table(dataframe_features)
```

Rename the column to `feature_id` and  `feature_name`
```{r}
setnames(Data_features, names(Data_features), c("feature_id", "feature_name"))
```

Features is the different variable that contains in Data_set for example Data_set$V1 is the features[1], Data_set$V2 is the features[2]
They ask to extract the features with mean and standard deviation for that we need to find in the features (inside feature_name) which variable contain the word mean() or std() (This is specify in features_info.txt)

Create a vector that give us the different variable that contains mean and std
```{r}
my_logical_features <- grep ("mean\\(\\)|std\\(\\)", Data_features$feature_name)
```

Select in the dataset the variables with mean and std throught the logical_features. Because the logical_features doesn't extract the subject_id column and activity_id column we should add again.

```{r}
Data_set_mean_std <- Data_set[,my_logical_features,with=FALSE]
Data_set_mean_std$subject_id <- Data_set$subject_id
Data_set_mean_std$activity_id <- Data_set$activity_id
```

3. Uses descriptive activity names to name the activities in the data set 
-------------------------------------------------------------------------
We should use activity name insteand of activity_id. Let's read **activity_labels.txt**  where we have the relations between `activity_id` and the `activity_name`. For that we are going to read **activity_labels.txt** and name the columns with appropiate name

```{r}
dataframe_activity_labels <- read.table(file.path(path_dataset,"activity_labels.txt"))
Data_activity_labels <- data.table(dataframe_activity_labels)
setnames(Data_activity_labels, names(Data_activity_labels), c("activity_id", "activity_name"))
Data_set_mean_std <- merge(Data_set_mean_std, Data_activity_labels, by="activity_id", all.x=TRUE)
```

Now we need to order the column because activity_id is the first column, and we want to have the features first.
```{r}
order_column<-names(Data_set_mean_std)[c(2:dim(Data_set_mean_std)[2],1)]
setcolorder(Data_set_mean_std, order_column)
```


4. Appropriately labels the data set with descriptive variable names. 
---------------------------------------------------------------------
We need to select the features without mean and name.

```{r}
Data_features_logical <- Data_features[my_logical_features,]
setnames(Data_set_mean_std, names(Data_set_mean_std)[1:dim(Data_features_logical)[1]], as.character(Data_features_logical$feature_name))
```

5.Create tidy data set with the average of each variable for each activity and each subject. (using dataset in step 4)
-----------------------------------------------------------------------------------------------------------------------
We are going to use aggreate for make a subset for each activity and subject, and create the mean.

Let's take the column we want to make the average. The last 3 element are subject_id, activity_name and activity_id. For that reason we want to don't select this column and selecte the rest.

```{r}
column_selected <- 1:((dim(Data_set_mean_std)[2])-3)
Data_tidy<-aggregate(Data_set_mean_std[,column_selected,with=FALSE],
                   (list(Data_set_mean_std$activity_name, Data_set_mean_std$subject_id)),mean)
```

We rename the column 1 and 2 which are the activity_name and subject_id

```{r}
setnames(Data_tidy, names(Data_tidy)[1:2], c("Activity_Name", "Subject_Id"))
```


Create the tidy data
--------------------

```{r}
f <- file.path(path, "tidy_data.txt")
write.table(Data_tidy, f, quote = FALSE, sep = "\t", row.names = FALSE)
```




