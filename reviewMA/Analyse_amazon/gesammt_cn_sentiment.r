# Uebung zur Sentiment Analysis 
# Blog http://stackoverflow.com/questions/22116938/twitter-sentiment-analysis-w-r-using-german-language-set-sentiws 
# dt. pos./neg. Wörter Senti... http://asv.informatik.uni-leipzig.de/download/sentiws.html 
# engl. pos./neg. Words:  http://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html 

setwd("/home/wei/Dropbox/Master Arbeit/reviewMA/Analyse_amazon") 
pdf("gesammt_cn_sentiment.pdf")
# setwd("F:/FP_Data_Mining/R")
sink("gesammt_cn_sentiment.txt", append=TRUE)

# load the wordlists

readAndflattenSentiWS <- function(filename) { 
  words = readLines(filename, encoding="UTF-8")
  words <- sub("\\|[A-Z]+\t[0-9.-]+\t?", ",", words)
  words <- unlist(strsplit(words, ","))
  words <- tolower(words)
  return(words)
}
pos.words <- c(scan("positive-words.txt",what='character', comment.char=';', quiet=T), 
               readAndflattenSentiWS("SentiWS_v1.8c_Positive.txt"))
neg.words <- c(scan("negative-words.txt",what='character', comment.char=';', quiet=T), 
              readAndflattenSentiWS("SentiWS_v1.8c_Negative.txt"))
#    pos.words = scan("positive-words.txt",what='character', comment.char=';')
#    neg.words = scan("negative-words.txt",what='character', comment.char=';')

        # bring in the sentiment analysis algorithm
        # we got a vector of sentences. plyr will handle a list or a vector as an "l" 
        # we want a simple array of scores back, so we use "l" + "a" + "ply" = laply:
        score.sentiment = function(sentences, pos.words, neg.words, .progress='none')
         { 
          require(plyr)
          require(stringr)
            scores = laply(sentences, function(sentence, pos.words, neg.words) 
            {
             # clean up sentences with R's regex-driven global substitute, gsub():
             sentence = gsub('[[:punct:]]', '', sentence)
             sentence = gsub('[[:cntrl:]]', '', sentence)
             sentence = gsub('\\d+', '', sentence)
             # and convert to lower case:
             sentence = tolower(sentence)
             # split into words. str_split is in the stringr package
             word.list = str_split(sentence, '\\s+')
             # sometimes a list() is one level of hierarchy too much
             words = unlist(word.list)
             # compare our words to the dictionaries of positive & negative terms
             pos.matches = match(words, pos.words)
             neg.matches = match(words, neg.words)
             # match() returns the position of the matched term or NA
             # we just want a TRUE/FALSE:
             pos.matches = !is.na(pos.matches)
             neg.matches = !is.na(neg.matches)
             # and conveniently enough, TRUE/FALSE will be treated as 1/0 by sum():
             score = sum(pos.matches) - sum(neg.matches)
             return(score)
            }, 
          pos.words, neg.words, .progress=.progress )
          scores.df = data.frame(score=scores, text=sentences)
          return(scores.df)
         }

    # and to see if it works, there should be a score...either in German or in English

sample <- c("ich liebe dich. du bist wunderbar",
            "Ich hasse dich, geh sterben!", 
            "i love you. you are wonderful.",
            "i hate you, die.")
(test.sample <- score.sentiment(sample, 
                                pos.words, 
                                neg.words))


# Kuehlschrank-Kommentare

Daten <-read.csv("gesammt_cn_translated.csv", header=TRUE,fileEncoding = "UTF-8", sep = ";")
n=dim(Daten)[1]

###
### Select comments
###
Comments <- matrix(1,n,1)
for (i in 1:n){
  if (Daten[i,3]>=0)  
    Comments[i]=paste(Daten[i,1],Daten[i,2]) 
              }

Comments[1:20]

a <- (test.sample <- score.sentiment(Comments, 
                                pos.words, 
                                neg.words))

Scores=a$score
Sterne=Daten[,3]
plot(Sterne,Scores)
title("Vergleich")
Scores
mean(Sterne)
mean(Scores)
var(Sterne)
var(Scores)
cov(Scores,Sterne)
cor(Scores,Sterne)
table(Sterne, Scores)

sink()
dev.off()








