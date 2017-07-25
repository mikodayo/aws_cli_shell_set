## This page is memo for cli script.

## reference 
### ami
http://qiita.com/bohebohechan/items/891120175efc1b3cc7c4
### delete ec2
http://qiita.com/tcsh/items/f2ac887777d374b1ad61

## S3
### フォルダ配下のファイルサイズ合計を算出する
    $> aws s3 ls s3://${bucket name}/${folder name}/  --recursive --human --sum 

## EC2
### リージョン内で稼働している全インスタンスの情報取得
    $> aws ec2 describe-instances
    
### インスタンスIDを指定して詳細情報を取得
    $> aws ec2 describe-instances --instance-ids ${instance-id}

### インスタンスの情報を取得
    $> aws ec2 describe-instances --instance-id  ${instance-id} --output json

### タグの名前を付ける
    $> aws ec2 create-tags --resources  ${instance-id} --tags '[{"Key": "Name", "Value": "Test"}]'

### Elastic IPを付与
    $> aws ec2 associate-address --allocation-id ${eipalloc-XXX} --network-interface-id ${eni-XXXXX}

### EC2を削除
    $> aws ec2 terminate-instances --instance-id ${instance-id}

## AMI
AMI起動に必要な情報はすでに起動しているAMIから取得してそれを充てればOK
現在起動中のインスタンス詳細を取得しておき、AMIから起動したインスタンスの詳細と比較する
指定したインスタンスIDのAMIを作成する

    $> aws ec2 create-image --instance-id ${instance-id} --name "My server" --description "An AMI for my server"

### AMIを指定してインスタンスを立てる (--dry-runなので実際には実行されない)
    $> aws ec2 run-instances  --dry-run --image-id ami-XXXX  --key-name demo --count 1 --security-group-ids sg-XXXX  --subnet-id subnet-XXXX --instance-type t2.micro

### インスタンスを起動し起動したinstance_idにタグを付ける
    $> aws ec2 run-instances [--command option] | jq -r '.Instances[0].InstanceId' | xargs -IINSTANCE_ID aws ec2 create-tags --resources INSTANCE_ID  --tags Key=Name,Value=${instance-id}
    
### 起動しているインスタンスから必要情報を取得する


### dry-runをはずしてAMIを指定してインスタンスを立てる
    $> aws ec2 run-instances  --image-id ami-XXXX --key-name demo --count 1 --security-group-ids sg-XXXX  --subnet-id subnet-XXXX --instance-type t2.micro
    
    必要な引数
    ・--image-id
    ・--key-name
    ・--count 1
    ・--security-group-ids
    ・--subnet-id
    ・--instance-type

### 指定したインスタンスIDのAMIのID(ImageId)を取得する
    $> aws ec2 describe-instances --instance-ids ${instance-id} | jq -r '.Reservations[].Instances[].ImageId'

## Elastic IP
 関連づけられていないElastic IPをチェックする

## RDS
### RDS 作成
    $> aws rds create-db-instance \
    --db-instance-identifier MySQLForLambdaTest \
    --db-instance-class db.t2.micro \
    --engine MySQL \
    --allocated-storage 5 \
    --no-publicly-accessible \
    --db-name ExampleDB \
    --master-username username \
    --master-user-password password \
    --backup-retention-period 3 

## IAM
### 指定したIAMロールのArnを取得する
    $aws iam get-role --role-name hello_exec_role |jq -r  .'Role.Arn'
    
