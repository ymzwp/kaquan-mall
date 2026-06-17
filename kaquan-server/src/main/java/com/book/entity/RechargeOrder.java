package com.book.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 充值订单表
 */
@Data
@TableName("recharge_order")
public class RechargeOrder {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    private Integer userId;

    /** 订单编号（唯一） */
    private String orderNo;

    /** 充值金额 */
    private BigDecimal amount;

    /** 支付方式: alipay/wechat/bank */
    private String payMethod;

    /** 订单状态: pending/success/canceled */
    private String status;

    /** 充值前余额 */
    private BigDecimal balanceBefore;

    /** 充值后余额 */
    private BigDecimal balanceAfter;

    /** 备注 */
    private String remark;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    @TableLogic
    private Integer deleted;
}
