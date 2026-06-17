package com.book.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 用户表（匹配 coupon_mall 实际表结构）
 */
@Data
@TableName("user")
public class User {

    @TableId(type = IdType.AUTO)
    private Integer id;

    /** 用户名 */
    private String username;

    /** 密码（加密存储） */
    private String password;

    /** 昵称 */
    private String nickName;

    /** 头像URL */
    private String avatar;

    /** 账户余额 */
    private BigDecimal balance;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
