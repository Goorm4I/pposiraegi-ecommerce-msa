package cloud.pposiraegi.product.global.image;

import org.springframework.web.multipart.MultipartFile;

public interface ImageStorageService {
    String uploadImage(MultipartFile file, String directory);
}
