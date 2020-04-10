const AWS = require('aws-sdk');

var ec2 = new AWS.EC2();


exports.handler = async (event, context) => {

    var ids =[]

    try {
        
        var region     = event['region']
        var detail     = event['detail']
        var eventname  = detail['eventName']
        var arn        = detail['userIdentity']['arn']
        var principal  = detail['userIdentity']['principalId']
        var user_type  = detail['userIdentity']['type']
        var user                

        if (user_type === 'IAMUser'){
            user = detail['userIdentity']['userName']
        } else if (user_type === 'Root'){
            user = 'Root'
        }else{
            user = principal.split(': ')[1]
        }

        if (!detail['responseElements']){
            console.log('no responseElements found')
            if (detail['errorCode']){
                console.log('errorCode ', detail['errorCode'])
            }
            if (detail['errorMessage']){
                console.log('errorMessage ', detail['errorMessage'])
            }

            return false
        }
        
        console.log("region ", region)
        console.log("detail ", detail)
        console.log("eventname ", eventname)
        console.log("arn ", arn)
        console.log("principal ", principal)
        console.log("user_type ", user_type)
        console.log("user ", user)

        if (eventname === 'CreateVolume'){
            ids.push(detail['responseElements']['volumeId'])
            console.log(ids)
        } else if(eventname === 'RunInstances'){
            var items =detail['responseElements']['instancesSet']['items']
            var item
            for ( item of items ){
                ids.push(item['instanceId'])
            } 
            console.log(ids)
            console.log('number of ids ', ids.length)
            var params = {InstanceIds: ids}

            ec2.describeInstances(params, function(err, data) {
                if (err) {
                    console.log(err, err.stack)
                }
                else{
                    console.log('describeInstances ', data)
                }
            })
        } else if (eventname === 'CreateImage'){
            ids.push(detail['responseElements']['imageId'])
        } else if (eventname === 'CreateSnapshot'){
            ids.push(detail['responseElements']['snapshotId'])
        } else {
            console.log('Not supported action')
        }

        if (ids.length>0){
            var params = {
                Resources: ids,
                Tags: [
                    { Key: "Owner", Value: user },
                    { Key: "PrincipalId", Value: principal }
                ]
            }

            await ec2.createTags(params).promise()
            
        }

        console.log('Done tagging')

        return true

    } catch (error) {

        console.log('error: ',error)

    }

}