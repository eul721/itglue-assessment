const http = require('http');
const IncomingForm = require('formidable').IncomingForm;
const fs = require('fs');
const AWS = require('aws-sdk');
const S3 = new AWS.S3();

const S3_BUCKET = process.env.S3_BUCKET_LOCATION;

(async ()=>{
  
  const server = http.createServer((req, res) => {
    const { headers, method, url } = req;
    if (url == '/') {
      res.writeHead(302,{Location: '/upload'})
      res.end()
    }
    if (method == 'GET' && url == '/upload'){
      res.write(`
      <!DOCTYPE html>
      <html>
        <head>
        <title>ITGlue Assessment</title>
        </head>
        
        <body>
          <form action="/upload" method="post" enctype="multipart/form-data">
            <label for="req_file">
              Provide your file here.
            </label>
            <input type="file" name="req_file" id="req_file" />
            <br/>
            <input type="submit" name="submit" value="Upload to S3">
          </form>
        </body>
      </html>`)
      res.end()
    } else if (method == 'POST' && url == '/upload'){
      const form = new IncomingForm()
      form.parse(req, async (err,fields,files)=>{
        file = files.req_file;
        let file_location = ""

        try{
          const fileContent = fs.readFileSync(file.path)
          const putObjectPromise = S3.putObject({ Bucket: S3_BUCKET, Key: file.name, Body: fileContent }).promise()
          await putObjectPromise
          file_location = `https://${S3_BUCKET}.s3.amazonaws.com/${file.name}`
        } catch(err) {
          console.error(err)
          file_location = "Upload failed."
        } finally {
          res.end(`
          <!DOCTYPE html>
          <html>
          <head>
          </head>
          <body>
            File location: <a href="${file_location}">${file_location}</a>
          </body>
          `)
        }
        
      })
      // form.on('file', function (name, file){
      //     console.log('Uploaded ' + file.name);
      //     res.end()
      // });
    }
  })
  
  server.listen(8080,'0.0.0.0');
  console.log("listening port " + 8080);
})();

