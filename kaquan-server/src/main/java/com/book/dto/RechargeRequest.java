package com.book.dto;

import lombok.Data;

import javax.validation.constraints.DecimalMax;
import javax.validation.constraints.DecimalMin;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;

/**
 * 充值请求参数
 */
@Data
public class RechargeRequest {

    @NotNull(message = "充值金额不能为空")
    @DecimalMin(value = "1.00", message = "充值金额不能小于1元")
    @DecimalMax(value = "5000.00", message = "充值金额不能超过5000元")
    private BigDecimal amount;

    @NotNull(message = "支付方式不能为空")
    private String payMethod;
}
