package cloud.pposiraegi.gateway.filter;

import cloud.pposiraegi.common.constants.AuthConstants;
import cloud.pposiraegi.common.dto.ApiResponse;
import cloud.pposiraegi.common.exception.ErrorCode;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.Getter;
import lombok.NonNull;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;
import tools.jackson.databind.ObjectMapper;

import javax.crypto.SecretKey;

@Slf4j
@Component
public class JwtAuthFilter extends AbstractGatewayFilterFactory<JwtAuthFilter.Config> {

    private final ObjectMapper objectMapper;

    private final SecretKey key;

    public JwtAuthFilter(ObjectMapper objectMapper, @Value("${jwt.secret}") String secretKey) {
        super(Config.class);
        this.objectMapper = objectMapper;
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        this.key = Keys.hmacShaKeyFor(keyBytes);
    }

    @Override
    @NonNull
    public GatewayFilter apply(Config config) {
        return (exchange, chain) -> {
            ServerHttpRequest request = exchange.getRequest();

            if (!request.getHeaders().containsHeader(HttpHeaders.AUTHORIZATION)) {
                return onError(exchange, ErrorCode.HEADER_NOT_FOUND);
            }

            String authHeader = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return onError(exchange, ErrorCode.INVALID_TOKEN_FORMAT);
            }

            String token = authHeader.replace("Bearer ", "").trim();

            try {
                Claims claims = Jwts.parser()
                        .verifyWith(key)
                        .build()
                        .parseSignedClaims(token)
                        .getPayload();

                String userId = claims.getSubject();

                ServerHttpRequest modifiedRequest = request.mutate()
                        .header(AuthConstants.USER_ID_HEADER, userId)
                        .build();

                return chain.filter(exchange.mutate().request(modifiedRequest).build());

            } catch (ExpiredJwtException e) {
                return onError(exchange, ErrorCode.EXPIRED_ACCESS_TOKEN);
            } catch (Exception e) {
                return onError(exchange, ErrorCode.INVALID_TOKEN);
            }
        };
    }

    private Mono<Void> onError(ServerWebExchange exchange, ErrorCode errorCode) {
        log.warn("권한 에러");
        ServerHttpResponse response = exchange.getResponse();
        response.setStatusCode(HttpStatus.UNAUTHORIZED);
        response.getHeaders().setContentType(MediaType.APPLICATION_JSON);

        ApiResponse<?> errorResponse = ApiResponse.error(errorCode);

        try {
            byte[] bytes = objectMapper.writeValueAsBytes(errorResponse);
            response.getHeaders().setContentLength(bytes.length);
            DataBuffer buffer = response.bufferFactory().wrap(bytes);

            return response.writeWith(Mono.just(buffer));
        } catch (Exception e) {
            return response.setComplete();
        }
    }

    @Getter
    @Setter
    public static class Config {
    }
}