const AWS = require('aws-sdk');

var ec2 = new AWS.EC2();


exports.handler = async (event, context) => {

    console.log('event: ',event)

    var ids =[]

    try {
        
        var region=event['region']
        var detail=evetn['detail']
        var eventname=detail['eventName']
        var arn=detail['userIdentity']['arn']
        var principal=detail['userIdentity']['principalId']
        var user_type=detail['userIdentity']['type']
        var user

        if (user_type == 'IAMUser'){
            user = detail['userIdentity']['userName']
        }else{
            user = principal.split(': ')[1]
        }

    } catch (error) {

    }

}