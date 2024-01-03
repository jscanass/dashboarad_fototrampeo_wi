library(rsconnect)
    
rsconnect::setAccountInfo(name='jcanas',
			token='xxxxxxxxxxxx',
			secret='xxxxxxxxxxxx')

rsconnect::deployApp('app', appName='DCT2023')