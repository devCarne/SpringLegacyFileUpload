<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<script src="https://code.jquery.com/jquery-3.6.0.js"></script>
<html>
<head>
    <title>Title</title>
<style>
    .uploadResult {
        width: 100%;
        background-color: gray;
    }

    .uploadResult ul {
        display: flex;
        flex-flow: row;
        justify-content: center;
        align-items: center;
    }

    .uploadResult ul li {
        list-style: none;
        padding: 10px;
        align-content: center;
        text-align: center;
    }

    .uploadResult ul li img {
        width: 100px;
    }

    .uploadResult ul li span {
        color: white;
    }

    .bigPictureWrapper {
        position: absolute;
        display: none;
        justify-content: center;
        align-items: center;
        top: 0;
        width: 100%;
        height: 100%;
        z-index: 100;
        background: rgba(255, 255, 255, 0.7);
    }

    .bigPicture {
        position: relative;
        display: flex;
        justify-content: center;
        align-items: center;
    }

    .bigPicture img {
        width: 600px;
    }
</style>
</head>

<body>
<h1>Upload with Ajax</h1>
<%--업로드 창--%>
<div class="uploadDiv">
    <input type="file" name="uploadFile" multiple>
</div>

<button id="uploadBtn">Upload</button>
<%--업로드 결과창--%>
<div class="uploadResult">
    <ul>

    </ul>
</div>

<%--원본 이미지 창--%>
<div class="bigPictureWrapper">
    <div class="bigPicture">
    </div>
</div>
</body>
</html>

<script>

    //업로드 대상 파일 체크 함수
    const regex = new RegExp("(.*?)\.(exe|sh|zip|alz)$");
    const maxSize = 5242880; //5MB

    function checkExtension(fileName, fileSize) {
        if (fileSize >= maxSize) {
            alert("파일 사이즈 초과");
            return false;
        }

        if (regex.test(fileName)) {
            alert("해당 종류의 파일은 업로드 할 수 없습니다.");
            return false;
        }

        return true;
    }

    //ajax 결과 출력 함수
    let uploadResult = $(".uploadResult ul");

    function showUploadFile(uploadResultArr) {
        let str = "";
        let fileCallPath;
        $(uploadResultArr).each(function (i, obj) {

            if (!obj.image) {
                fileCallPath = encodeURIComponent(obj.uploadPath + "/" + obj.uuid + "_" + obj.fileName);

                let fileLink = fileCallPath.replace(new RegExp(/\\/g), "/");

                str += "<li>" +
                    "       <div>" +
                    "           <a href='/download?fileName=" + fileCallPath + "'>" +
                    "               <img src='/resources/img/attach.png'>" + obj.fileName + "</a>" +
                    "           <span data-file=\'" + fileCallPath + "\' data-type='file'> x </span>" +
                    "       </div>" +
                    "   </li>";
            } else {
                fileCallPath = encodeURIComponent(obj.uploadPath + "/s_" + obj.uuid + "_" + obj.fileName);

                console.log(fileCallPath)
                let originPath = obj.uploadPath + "\\" + obj.uuid + "_" + obj.fileName;
                originPath = originPath.replace(new RegExp(/\\/g), "/");

                str += "<li>" +
                    "       <a href=\"javascript:showImage(\'" + originPath + "\')\">" +
                    "           <img src='/display?fileName=" + fileCallPath + "'>" + obj.fileName + "</a>" +
                    "       <span data-file=\'" + fileCallPath + "\' data-type='image'> x </span>" +
                    "   </li>";
            }
        });
        uploadResult.append(str)
    }

    //원본 이미지 보여주기
    function showImage(fileCallPath) {
        $(".bigPictureWrapper").css("display", "flex").show();

        $(".bigPicture")
        .html("<img src='/display?fileName=" + encodeURI(fileCallPath) + "'>")
        .animate({width:'100%', height:'100%'}, 1000);
    }


    //input type="file"은 readonly. 미리 복사해두고 바꿔준다.
    let cloneObj = $(".uploadDiv").clone();

    $(document).ready(function () {
        //파일 업로드 ajax
        $("#uploadBtn").on("click", function (){
            let formData = new FormData();
            let inputFile = $("input[name='uploadFile']");
            let files = inputFile[0].files;

            for (let i = 0; i < files.length; i++) {
                if (!checkExtension(files[i].name, files[i].size)) {
                    return false;
                }
                formData.append("uploadFile", files[i]);
            }

            $.ajax({
                url: "/uploadAjaxAction",
                processData: false,
                contentType: false,
                data: formData,
                type: "POST",
                dataType: "json",
                success: function (result) {
                    console.log(result);

                    showUploadFile(result);
                    //업로드 창 초기화
                    $(".uploadDiv").html(cloneObj.html());
                }
            });
        });//파일 업로드 ajax

        //원본 이미지 보기 닫기
        $(".bigPictureWrapper").on("click", function (e) {
            $(".bigPicture").animate({width: '0%', height: '0%'}, 1000);
            setTimeout(function () {
                $('.bigPictureWrapper').hide();
            }, 1000);
        });//원본 이미지 보기 닫기

        //파일 삭제
        $(".uploadResult").on("click", "span", function (e) {
            let targetFile = $(this).data("file");
            let type = $(this).data("type");
            console.log(targetFile);

            $.ajax({
                url: '/deleteFile',
                data: {fileName: targetFile, type: type},
                dataType: 'text',
                type: 'POST',
                success: function (result) {
                    alert(result);
                }
            });
        });//파일 삭제
    });

</script>
