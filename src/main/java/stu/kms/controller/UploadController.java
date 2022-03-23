package stu.kms.controller;

import lombok.extern.log4j.Log4j;
import net.coobird.thumbnailator.Thumbnailator;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import stu.kms.domain.AttachFileDTO;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;

@Controller
@Log4j
public class UploadController {

    String uploadFolder = "C:\\upload";

    private String getFolder() {
        Date date = new Date();

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String str = sdf.format(date);

        return str.replace("-", File.separator);
    }

    private boolean checkImageType(File file) {
        try {
            String contentType = Files.probeContentType(file.toPath());
            //알려지지 않은 확장자 파일을 업로드 시 NullPointException 발생. 그래서 아래와 같이 처리했다.
            if (contentType == null) return false;
            return contentType.startsWith("image");
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    @GetMapping("/uploadForm")
    public void uploadForm() {
        log.info("upload form");
    }

    @PostMapping("/uploadFormAction")
    public void uploadFormPost(MultipartFile[] uploadFile, Model model) {
        for (MultipartFile multipartFile : uploadFile) {
            log.info("----------------------------------");
            log.info("Upload File Name : " + multipartFile.getOriginalFilename());
            log.info("Upload File Size : " + multipartFile.getSize());

            File saveFile = new File(uploadFolder, multipartFile.getOriginalFilename());

            try {
                multipartFile.transferTo(saveFile);
            } catch (Exception e) {
                log.error(e.getMessage());
            }
        }
    }

    @GetMapping("/uploadAjax")
    public void uploadAjax() {
        log.info("upload ajax");
    }

    @PostMapping(value = "/uploadAjaxAction", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public ResponseEntity<List<AttachFileDTO>> uploadAjaxPost(MultipartFile[] uploadFile) {

        List<AttachFileDTO> list = new ArrayList<>();

        //        폴더 자동 생성
        String uploadSubPath = getFolder();
        File uploadPath = new File(uploadFolder, uploadSubPath);
        if (!uploadPath.exists()) uploadPath.mkdirs();

        //        파일 저장
        for (MultipartFile multipartFile : uploadFile) {

            AttachFileDTO attachDTO = new AttachFileDTO();

            attachDTO.setUploadPath(uploadSubPath);

            //Internet Explorer 구버전에서는 경로가 모두 출력되므로 경로를 잘라준다.
            String tempFileName = multipartFile.getOriginalFilename();
            String uploadFileName = tempFileName.substring(tempFileName.lastIndexOf("\\") + 1);

            attachDTO.setFileName(uploadFileName);

            //임의의 값을 파일명 앞에 붙여 중복을 방지한다.
            //나중에 _를 기준으로 분리하면 원래 파일명도 복원할 수 있다.
            UUID uuid = UUID.randomUUID();
            uploadFileName = uuid + "_" + uploadFileName;

            attachDTO.setUuid(uuid.toString());

            //최종적으로 저장되는 파일
            try {
                File saveFile = new File(uploadPath, uploadFileName);
                multipartFile.transferTo(saveFile);
                //이미지 파일 여부를 체크하고 썸네일 생성
                if (checkImageType(saveFile)) {
                    attachDTO.setImage(true);

                    FileOutputStream fos = new FileOutputStream(new File(uploadPath, "s_" + uploadFileName));

                    //매개변수 : (InputStream, OutputStream, width, height)
                    Thumbnailator.createThumbnail(multipartFile.getInputStream(), fos, 100, 100);
                    fos.close();
                }
                list.add(attachDTO);

            } catch (Exception e) {
                e.printStackTrace();
            }
        }//for
        return new ResponseEntity<>(list, HttpStatus.OK);
    }

    @GetMapping("/display")
    @ResponseBody
    public ResponseEntity<byte[]> getFile(String fileName) {
        File file = new File(uploadFolder + "\\" + fileName);
        log.info("file : " + file);

        ResponseEntity<byte[]> result = null;
        try {
            HttpHeaders header = new HttpHeaders();

            header.add("Content-Type", Files.probeContentType(file.toPath()));
            result = new ResponseEntity<>(FileCopyUtils.copyToByteArray(file), header, HttpStatus.OK);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return result;
    }
}
