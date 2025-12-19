Install ampq library:
go get github.com/streadway/amqp


go run producer.go


The <-forever line at the end of the file means we'll keep listening to the channel for new messages.