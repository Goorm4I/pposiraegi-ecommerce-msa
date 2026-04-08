package cloud.pposiraegi.user.domain.user.dto;

import cloud.pposiraegi.user.domain.user.entity.UserAddress;

public class UserAddressInfoDto {
    public record UserAddressInfo(
            Long addressId,
            String recipientName,
            String phoneNumber,
            String secondaryPhoneNumber,
            String zipCode,
            String baseAddress,
            String detailAddress,
            String requestMessage
    ) {
        public static UserAddressInfo from(UserAddress address) {
            return new UserAddressInfo(
                    address.getId(),
                    address.getRecipientName(),
                    address.getPhoneNumber().getValue(),
                    address.getSecondaryPhoneNumber() != null ? address.getSecondaryPhoneNumber().getValue() : null,
                    address.getZipCode(),
                    address.getBaseAddress(),
                    address.getDetailAddress(),
                    address.getRequestMessage()
            );
        }
    }
}
