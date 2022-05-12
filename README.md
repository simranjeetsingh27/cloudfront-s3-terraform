# cloudfront-s3-terrform


For running the Terraform script:


1. terraform init

2. terrform apply 

3. You can input the environment name , application name tag to create the s3 bucket with name as environmentname-application name
   eg : dev-demohari-s3
   
 The Terrform script will do the following things 


1. Create cloudfront and s3
2. Integrate cloudfront and s3
3. Enable Static website hosting in S3
4. Kept the s3 as private and enable encryption with default encryption key \
5. Put the index page(Default root object) as "index.html"
6. Enable compression 
7. Enable Price class 200 (Edge location : North America, Europe, Asia, Middle East, and Africa)
8. Redirect HTTP to HTTPS 
9. Input a rewrite rule in s3 (you can update the rule by adding it in script)




If you are facing any error related with message "conflicting conditional operation is currently in progress" rerun the script again with same input fields to enable private policy in s3 bucket.

