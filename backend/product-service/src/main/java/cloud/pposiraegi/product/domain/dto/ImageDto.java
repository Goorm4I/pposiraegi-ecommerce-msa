package cloud.pposiraegi.product.domain.dto;

import cloud.pposiraegi.product.domain.enums.ImageType;

public class ImageDto {
    public record ImageResponse(
            String imageUrl,
            ImageType imageType,
            Integer displayOrder
    ) {
    }
}
