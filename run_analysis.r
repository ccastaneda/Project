#Here are the data for the project: 

# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

#You should create one R script called run_analysis.R that does the following. 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the average 
#    of each variable for each activity and each subject.

##### Read the data
library(reshape2)
require(data.table)

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileName <- "dataSet.zip"

if (!file.exists(fileName)){
	print("downloading file")
	download.file(fileUrl, fileName)
}
#
## unzip the file
if (!file.exists("UCI HAR Dataset")) { 
	print("unzip file")
	unzip(fileName)
} 
#

#Read files: 
# activity_labels.txt;two columns V1 (id 1-6); V2(txt WALKING ..)
# features.txt; two columns V1 (id 1-561); V2 (txt fBodyBodyGyroJerkMag-meanFreq()...) 
 
 activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
 features <- read.table("UCI HAR Dataset/features.txt")
#print("Read Activity and Features from dataset") 
#Extracts only the measurements on the mean and standard deviation for 
#each measurement

measuresWanted <- grep(".*mean.*|.*std.*", features[,2])

#Uses descriptive activity names to name the activities in the data set
#from "tBodyAcc-std()-Z" to "tBodyAccSTDZ" 

measuresNames <-features[measuresWanted,2]
measuresNames =gsub('-mean', 'Mean', measuresNames)
measuresNames =gsub('-std', 'STD', measuresNames)
measuresNames =gsub('[()-]', '', measuresNames)
#print("measures names")
#print (head(measuresNames, n=5))
#Read datasets: train  and label with relevant information 

train <- read.table("UCI HAR Dataset/train/X_train.txt")[measuresWanted]

trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

#print("train dataset")
#print (head(train, n=3))

#Read datasets: test  and label with relevant information
test <- read.table("UCI HAR Dataset/test/X_test.txt")[measuresWanted]

testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

#print("test dataset")
#print (head(test, n=3))
#merge and label it
mergedTrainTestData <- rbind(train, test)
colnames(mergedTrainTestData) <- c("subject", "activity",measuresNames)

#print("mergeData")
#print (head(mergedTrainTestData, n=3))

# turn activities & subjects into factors
mergedTrainTestData$activity <- factor(mergedTrainTestData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
mergedTrainTestData$subject <- as.factor(mergedTrainTestData$subject)

# calculate the average of each variable and create a new dataset
meanAndStd <- mergedTrainTestData[,c(1,2, grep("STD", colnames(mergedTrainTestData)), grep("Mean", colnames(mergedTrainTestData)))]
write.table(meanAndStd, "tidy.txt", row.names = FALSE, quote = FALSE)
