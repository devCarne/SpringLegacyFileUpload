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
    }

    .uploadResult ul li img {
        width: 50px;
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

        $(uploadResultArr).each(function (i, obj) {

            if (!obj.image) {
                str += "<li><img src='/resources/img/attach.png'>" + obj.fileName + "</li>";
            } else {
                let fileCallPath = encodeURIComponent(obj.uploadPath + "/s_" + obj.uuid + "_" + obj.fileName);

                str += "<li><img src='/display?fileName=" + fileCallPath + "'>" + obj.fileName + "</li>";
            }
        });
        uploadResult.append(str)
    }

    //파일 업로드 ajax
    //input type="file"은 readonly. 미리 복사해두고 바꿔준다.
    let cloneObj = $(".uploadDiv").clone();

    $(document).ready(function () {
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
        });
    });

</script>
