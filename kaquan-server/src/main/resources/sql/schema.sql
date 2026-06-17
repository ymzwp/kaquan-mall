-- =============================================
-- 卡券商城 - 数据库初始化脚本
-- =============================================

CREATE DATABASE IF NOT EXISTS book_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE book_db;

-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
    `id`            BIGINT         NOT NULL AUTO_INCREMENT COMMENT '主键',
    `nick_name`     VARCHAR(64)    DEFAULT NULL     COMMENT '昵称',
    `avatar`        VARCHAR(512)   DEFAULT NULL     COMMENT '头像URL',
    `phone`         VARCHAR(16)    DEFAULT NULL     COMMENT '手机号',
    `password`      VARCHAR(256)   DEFAULT NULL     COMMENT '密码（加密）',
    `balance`       DECIMAL(12,2)  NOT NULL DEFAULT 0.00 COMMENT '账户余额',
    `member_level`  VARCHAR(16)    DEFAULT 'normal' COMMENT '会员等级',
    `invite_code`   VARCHAR(32)    DEFAULT NULL     COMMENT '邀请码',
    `invited_by`    BIGINT         DEFAULT NULL     COMMENT '被邀请人ID',
    `create_time`   DATETIME       DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`   DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`       TINYINT        DEFAULT 0     COMMENT '逻辑删除: 0-正常, 1-已删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_phone` (`phone`),
    KEY `idx_invite_code` (`invite_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 充值订单表
CREATE TABLE IF NOT EXISTS `recharge_order` (
    `id`              BIGINT         NOT NULL AUTO_INCREMENT COMMENT '主键',
    `user_id`         BIGINT         NOT NULL     COMMENT '用户ID',
    `order_no`        VARCHAR(32)    NOT NULL     COMMENT '订单编号',
    `amount`          DECIMAL(12,2)  NOT NULL     COMMENT '充值金额',
    `pay_method`      VARCHAR(16)    DEFAULT NULL COMMENT '支付方式: alipay/wechat/bank',
    `status`          VARCHAR(16)    NOT NULL DEFAULT 'pending' COMMENT '状态: pending-待支付, success-已支付, canceled-已取消',
    `balance_before`  DECIMAL(12,2)  DEFAULT 0.00 COMMENT '充值前余额',
    `balance_after`   DECIMAL(12,2)  DEFAULT 0.00 COMMENT '充值后余额',
    `remark`          VARCHAR(256)   DEFAULT NULL COMMENT '备注',
    `create_time`     DATETIME       DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`     DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`         TINYINT        DEFAULT 0   COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='充值订单表';

-- 测试用户（密码: 123456 的 BCrypt 密文）
INSERT INTO `user` (`id`, `nick_name`, `phone`, `password`, `balance`, `member_level`, `invite_code`)
VALUES (1, '测试用户', '13800138000', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5Eh', 32.94, 'normal', 'XJ51773');
