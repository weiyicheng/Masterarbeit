# Uebung zur Sentiment Analysis 
# Blog http://stackoverflow.com/questions/22116938/twitter-sentiment-analysis-w-r-using-german-language-set-sentiws 
# dt. pos./neg. Wörter Senti... http://asv.informatik.uni-leipzig.de/download/sentiws.html 
# engl. pos./neg. Words:  http://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html 

setwd("/home/wei/Dropbox/Master Arbeit/reviewMA/Sentiment_Analyse") 
pdf("puma_de_sentiment.pdf")
# setwd("F:/FP_Data_Mining/R")
sink("puma_de_sentiment.txt", append=TRUE)

PandN_words <-readLines("SentiWS.txt", encoding = "UTF-8")
PandN_words <-unlist(strsplit(PandN_words, ","))
PandN_words <- tolower(PandN_words)
#PandN_number=dim(PandN_words)[1]
require(plyr)
require(stringr)
library(tm)


score.sentiment = function(sentences, PandN_words, .progress='none')
         { 
          require(plyr)
          require(stringr)
           scores = laply(sentences, function(sentence, PandN_words) 
           {
            docs <- Corpus(VectorSource(sentence))
            ###
            ### Text transformation
            ###
            toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
            docs <- tm_map(docs, toSpace, "/")
            docs <- tm_map(docs, toSpace, "@")
            docs <- tm_map(docs, toSpace, "\\|")

            ###
            ### Cleaning the text
            ###
            # Convert the text to lower case
            docs <- tm_map(docs, content_transformer(tolower))

            # Remove numbers
            docs <- tm_map(docs, removeNumbers)

            # Remove common stopwords
            docs <- tm_map(docs, removeWords, stopwords("german"))

            # Remove your own stop word
            # specify your stopwords as a character vector
            docs <- tm_map(docs, removeWords, c("schon", "beim")) 

            # Remove punctuations
            docs <- tm_map(docs, removePunctuation)

            # Eliminate extra white spaces
            docs <- tm_map(docs, stripWhitespace)

            # Text stemming
            docs <- tm_map(docs,stemDocument,language="german")
            dataframe<-data.frame(text=unlist(sapply(docs, `[`, "content")), stringsAsFactors=F)
            word.list = str_split(dataframe, '\\s+')
            # sometimes a list() is one level of hierarchy too much
            words = unlist(word.list)
            scoreNumber = 0
            for (word in words) {
                result = match(word, PandN_words)
                if(!is.na(result)){
                       id = as.numeric(result) + 1
                       scoreNumber = scoreNumber + as.numeric(PandN_words[id])
                }
            }
            return(scoreNumber)
           }, 
         PandN_words, .progress=.progress )
         scores.df = data.frame(score=scores, text=sentences)
         return(scores.df)
        }

    # and to see if it works, there should be a score...either in German or in English

#sample <- c("ich liebe dich. du bist wunderbar",
#            "Ich hasse dich, geh sterben!", 
#            "gut gutes schlecht positives Ware .",
#            "nicht mehr kaufen best glücklich.")
#(test.sample <- score.sentiment(sample, PandN_words))

Daten <-read.csv("puma_de.csv", header=TRUE,fileEncoding = "UTF-8", sep = ",")
n=dim(Daten)[1]

###
### Select comments
###
Comments <- matrix(1,n,1)
for (i in 1:n){
  if (Daten[i,6]>=0){  
    Comments[i]=paste(Daten[i,7],Daten[i,8]) 
                    }
              }


a <- score.sentiment(Comments, PandN_words)
Scores=a$score


Sterne=Daten[,6]
plot(Sterne,Scores)
title("Vergleich")
Scores
print("Mean")
mean(Sterne)
mean(Scores)
print("Median")
median(Sterne, na.rm = FALSE)
median(Scores, na.rm = FALSE)
print("Varianz")
var(Sterne)
var(Scores)
print("Standardabweichung")
sd(Sterne)
sd(Scores)
print("Korrelationskoeffizient")
#cov(Scores,Sterne)
cor(Scores,Sterne)
t.test(Sterne)
t.test(Scores)
qqnorm(Sterne)
qqline(Sterne)
qqnorm(Scores)
qqline(Scores)
x <- table(Scores,Sterne)
dataSet<-data.frame(Scores,Sterne)
# Write CSV in R
write.csv(x, file = "pumaErgebnis_de.csv", na="")
h<-hist(dataSet$Scores, breaks=nrow(x),col="gray",main="Die Ergebnisse von deutschen OCRs für Puma in Frequenz", xlab="Polarität von OCRs durch Sentiment Analyse", ylab="Frequenz")
mtext("Blau ist die Gaußverteilungskurve",col="blue")
xfit <- seq(min(dataSet$Scores),max(dataSet$Scores),length=nrow(x))
yfit <- dnorm(xfit, mean = mean(dataSet$Scores), sd=sd(dataSet$Scores))
yfit<-yfit*diff(h$mids[1:3])*length(dataSet$Scores)
lines(xfit, yfit, col = "blue", lwd =2)
box()

hist(dataSet$Scores, breaks=nrow(x),freq=FALSE,col="gray",main="Die Ergebnisse von deutschen OCRs für Puma in Dichte", xlab="Polarität von OCRs durch Sentiment Analyse", ylab="Dichte")
mtext("Rot ist die Dichteverteilungskurve",col="red")
lines(density(dataSet$Scores), col="red", lwd=2)
box()

sink()
dev.off()


