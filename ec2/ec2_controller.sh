#!/bin/sh
########################################################
# 以下のクラスメソッド様シェルをアレンジさせていただきました。
# ありがとうございました。
# http://dev.classmethod.jp/cloud/aws/ec2-start-and-stop-script-on-linux/
#
########################################################
# -指定したタグのインスタンスを起動停止する。
# -- 起動時は設定したSIZEまでサイズを上げる
# -- 停止時は節約のためにインスタンスサイズをt1.microまで下げます。
# -- t1.microが使えない場合は環境に合わせて変更してください。
#
########################################################
# DEFAULT_REGION, TAG, SIZEを環境に合わせて変更してください。
########################################################
# cron設定サンプル UTCです。9時起動17:30停止。営業日のみ実行です。
#00 0 * * 1-5 /home/ec2-user/workspace/ec2control.sh --start >> ~/ec2control.log 2>&1
#30 8 * * 1-5 /home/ec2-user/workspace/ec2control.sh --stop >> ~/ec2control.log 2>&1
########################################################

 
DEFAULT_REGION='us-east-1'
TAG='TAG'
SIZE='t2.medium'

## タグからインスタンスIDを取得
INSTANCE_ID=`aws ec2 describe-instances --filters "Name=tag-key,Values=Name" --filters "Name=tag-value,Values=$TAG" | jq -r '.Reservations[].Instances[].InstanceId'`

echo ""
echo "instance-id:["$INSTANCE_ID"]"
 
## 指定インスタンスのステータス確認(aws ec2 describe-instances)
INSTANCE_STATUS=`aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $DEFAULT_REGION | jq -r '.Reservations[].Instances[].State.Name'`
echo "instance-status:["$INSTANCE_STATUS"]"
 
## 指定EC2インスタンスの起動(aws ec2 start-instances).
if [ -n "$1" ] && [ $1 = '--start' ] ; then
 
    if [ -n "$INSTANCE_STATUS" ] && [ $INSTANCE_STATUS = 'running' ] ; then
        ## 稼働中であれば特に何もしない.
        echo "status is running. nothing to do."
    else
        ## 停止中であれば起動指示.
        echo "status is stopped."
        ## インスタンスサイズを変更
        aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --attribute instanceType --value t2.medium
        sleep 10

        ## 起動
        aws ec2 start-instances --instance-ids $INSTANCE_ID --region $DEFAULT_REGION
        echo "ec2 instance starting..."
    fi
 
## 指定EC2インスタンスの停止(stop). 
elif [ -n "$1" ] && [ $1 = '--stop' ] ; then
 
    if [ -n "$INSTANCE_STATUS" ] && [ $INSTANCE_STATUS = 'running' ] ; then
        ## 稼働中であれば停止指示.
        echo "status is running."
        aws ec2 stop-instances --instance-ids $INSTANCE_ID --region $DEFAULT_REGION
        echo "ec2-instance stopping..."

        ## 停止が完了したらサイズを変更
        while [ $INSTANCE_STATUS != "stopped" ]
        do
            INSTANCE_STATUS=`aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $DEFAULT_REGION | jq -r '.Reservations[].Instances[].State.Name'`
            sleep 10
        done

        aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --attribute instanceType --value t2.micro

    else
        ## 停止中であれば何もしない.
        echo "status is stopped. nothing to do."
    fi
 
## 引数無しの場合は何もしない.
else
    if [ -z "$1" ] ; then
        echo "argument is required( --start / --stop ). nothing to do."
    else
        echo "argument is invalid. valid argument is --start or --stop."
    fi
fi
echo ""

