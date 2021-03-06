#install.packages("e1071")
library(caret)
library("e1071")
library(gridExtra)
library(grid)

#csvData <- file.choose()
csvData <- read.csv("output_tfidf.csv", header=T, sep=',')

#labelData <- file.choose()
labelData <- read.csv("Discussion_Category_Less5_2.csv", header=T, sep=',')

#labelList <- labelData[,c("Discussion.Category")]
#dim(labelData)
#dim(csvData)
#labelList <- labelList[]
labelList <- as.list(as.data.frame(t(labelData)))
integData <- cbind(csvData, labelData)
trainingDataSize <- floor(0.70 * nrow(integData))
set.seed(123)
train_ind <- sample(seq_len(nrow(integData)), size = trainingDataSize)
trainingData <- integData[train_ind, ]
testData <- integData[-train_ind, ]

numOfCols <- ncol(csvData)
xtrain = trainingData[,1:numOfCols]
ytrain = trainingData[,numOfCols+1]

###########PCA#######
#xtrainT <- t(xtrain)
#p <- prcomp(xtrain, retx=TRUE, center=TRUE, scale=TRUE)
accuracy = c()
p <- prcomp(xtrain)
for (i in 1:50) {
  pRot <- (p$rotation[,1:i])
  
  xtrainMat <- data.matrix(xtrain)
  xtrainMult <- xtrainMat %*% pRot
  
  #print(summary(p))
  
  #plot(p, type = "l")
  
  xtest = testData[,1:numOfCols]
  ytest = testData[,numOfCols+1]
  
  ##########PCA##########
  #xtestT <- t(xtest)
  pTest <- prcomp(xtest)
  pRotTest <- (pTest$rotation[,1:i])
  
  xtestMat <- data.matrix(xtest)
  xtestMult <- xtestMat %*% pRotTest
  
  tuneLinear = best.tune(svm,train.x=xtrainMult, train.y=ytrain,kernel ="linear")
  #print(summary(tuneLinear))
  linearModel <- svm( xtrainMult, ytrain, kernel = "linear", type = 'C', cost = 1, gamma = 0.02)
  
  tunePolynomial = best.tune(svm,train.x=xtrainMult, train.y=ytrain,kernel ="polynomial")
  #print(summary(tunePolynomial))
  polynomialModel <- svm( xtrainMult, ytrain, kernel = "polynomial", type = 'C', degree = 3, cost = 1, gamma = 0.02)
  
  tuneRadial = best.tune(svm,train.x=xtrainMult, train.y=ytrain,kernel ="radial")
  #print(summary(tuneRadial))
  radialModel <- svm( xtrainMult, ytrain, kernel = "radial", type = 'C', cost = 1, gamma = 0.02)
  
  tuneSigmoid = best.tune(svm,train.x=xtrainMult, train.y=ytrain,kernel ="sigmoid")
  #print(summary(tuneSigmoid))
  sigmoidModel <- svm( xtrainMult, ytrain, kernel = "sigmoid", type = 'C', cost = 1, gamma = 0.02)
  
  tuneQuadratic = best.tune(svm,train.x=xtrainMult, train.y=ytrain,kernel ="polynomial")
  #print(summary(tuneQuadratic))
  quadraticModel <- svm( xtrainMult, ytrain, kernel = "polynomial", type = 'C', degree = 3, cost = 1, gamma = 0.02)
  
  methods = c("linear","polynomial","radial","sigmoid","quadratic");
  
  precision = c()
  recall=c()
  FMeasure=c()
  # accuracy = c()
  classAccuracy = matrix(, nrow = 5, ncol = 5)
  classPrecision = matrix(, nrow = 5, ncol = 5)
  classRecall = matrix(, nrow = 5, ncol = 5)
  
  pred <- predict(sigmoidModel,xtestMult)
  confusionMatrix <- table(pred,ytest)
  A1 <- confusionMatrix[1,1]
  A2 <- confusionMatrix[1,2]
  A3 <- confusionMatrix[1,3]
  A4 <- confusionMatrix[1,4]
  A5 <- confusionMatrix[1,5]
  B1 <- confusionMatrix[2,1]
  B2 <- confusionMatrix[2,2]
  B3 <- confusionMatrix[2,3]
  B4 <- confusionMatrix[2,4]
  B5 <- confusionMatrix[2,5]
  C1 <- confusionMatrix[3,1]
  C2 <- confusionMatrix[3,2]
  C3 <- confusionMatrix[3,3]
  C4 <- confusionMatrix[3,4]
  C5 <- confusionMatrix[3,5]
  D1 <- confusionMatrix[4,1]
  D2 <- confusionMatrix[4,2]
  D3 <- confusionMatrix[4,3]
  D4 <- confusionMatrix[4,4]
  D5 <- confusionMatrix[4,5]
  E1 <- confusionMatrix[5,1]
  E2 <- confusionMatrix[5,2]
  E3 <- confusionMatrix[5,3]
  E4 <- confusionMatrix[5,4]
  E5 <- confusionMatrix[5,5]
  # grid.table(confusionMatrix)
  sumOfElements <- A1+A2+A3+A4+A5+B1+B2+B3+B4+B5+C1+C2+C3+C4+C5+D1+D2+D3+D4+D5+E1+E2+E3+E4+E5
  # accuracy[1]= (A1+B2+C3+D4+E5)/sumOfElements
  accuracy[i]= (A1+B2+C3+D4+E5)/sumOfElements
  classAccuracy[1,1] = A1/sumOfElements
  classAccuracy[1,2] = B2/sumOfElements
  classAccuracy[1,3] = C3/sumOfElements
  classAccuracy[1,4] = D4/sumOfElements
  classAccuracy[1,5] = E5/sumOfElements
  
  classPrecision[1,1] = A1/(A1+B1+C1+D1+E1)
  classPrecision[1,2] = B2/(A1+B1+C1+D1+E1)
  classPrecision[1,3] = C3/(A1+B1+C1+D1+E1)
  classPrecision[1,4] = D4/(A1+B1+C1+D1+E1)
  classPrecision[1,5] = E5/(A1+B1+C1+D1+E1)
  
  classRecall[1,1] = A1/(A1+A2+A3+A4+A5)
  classRecall[1,2] = B2/(A1+A2+A3+A4+A5)
  classRecall[1,3] = C3/(A1+A2+A3+A4+A5)
  classRecall[1,4] = D4/(A1+A2+A3+A4+A5)
  classRecall[1,5] = E5/(A1+A2+A3+A4+A5)
  #precision[1] <- A1/(A1+B1+C1+D1+E1)
  #recall[1] <- A1/(A1+A2+A3+A4+A5)
  #FMeasure[1] <- (2 * ( precision[1] * recall[1])/ ( precision[1] + recall[1] ))
}
print(accuracy)
plot(accuracy, type="o", col="blue")

