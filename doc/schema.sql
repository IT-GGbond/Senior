-- ============================================================
-- 银龄配办小程序 · 数据库建表脚本
-- 数据库：MySQL 8.x
-- 字符集：utf8mb4
-- 日期：2026-04
-- ============================================================

-- 创建数据库（如不存在）
CREATE DATABASE IF NOT EXISTS `silver_age` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE `silver_age`;

-- ============================================================
-- 1. 用户表
-- ============================================================
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `openid`      VARCHAR(64)  NOT NULL                COMMENT '微信openid',
    `nickname`    VARCHAR(50)  DEFAULT NULL             COMMENT '微信昵称',
    `avatar_url`  VARCHAR(255) DEFAULT NULL             COMMENT '头像URL',
    `name`        VARCHAR(20)  DEFAULT NULL             COMMENT '真实姓名',
    `phone`       VARCHAR(20)  DEFAULT NULL             COMMENT '手机号',
    `community`   VARCHAR(100) DEFAULT NULL             COMMENT '所在社区',
    `invite_code` VARCHAR(8)   DEFAULT NULL             COMMENT '邀请码（老人专属）',
    `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_openid` (`openid`),
    UNIQUE KEY `uk_invite_code` (`invite_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户表';

-- ============================================================
-- 2. 用户角色表（一个用户可拥有多个角色）
-- ============================================================
DROP TABLE IF EXISTS `user_role`;
CREATE TABLE `user_role` (
    `id`      BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT      NOT NULL                COMMENT '用户ID',
    `role`    VARCHAR(20) NOT NULL                COMMENT '角色：ELDERLY-老人 / FAMILY-家属 / VOLUNTEER-志愿者 / ADMIN-管理员',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_role` (`user_id`, `role`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户角色表';

-- ============================================================
-- 3. 家属绑定表（老人与家属 多对多）
-- ============================================================
DROP TABLE IF EXISTS `family_binding`;
CREATE TABLE `family_binding` (
    `id`          BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `elderly_id`  BIGINT      NOT NULL                COMMENT '老人用户ID',
    `family_id`   BIGINT      NOT NULL                COMMENT '家属用户ID',
    `relation`    VARCHAR(20) NOT NULL                COMMENT '关系：子女/配偶/亲属/其他',
    `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '绑定时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_elderly_family` (`elderly_id`, `family_id`),
    KEY `idx_elderly_id` (`elderly_id`),
    KEY `idx_family_id` (`family_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='家属绑定表';

-- ============================================================
-- 4. 流程模板表
-- ============================================================
DROP TABLE IF EXISTS `flow_template`;
CREATE TABLE `flow_template` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `name`        VARCHAR(100) NOT NULL                COMMENT '模板名称',
    `category`    VARCHAR(20)  NOT NULL                COMMENT '业务模块：GOVERNMENT-政务帮办 / LIFE-生活协助 / HEALTH-健康支持 / COMMUNITY-社区连接',
    `creator_id`  BIGINT       NOT NULL                COMMENT '创建人ID（管理员或家属）',
    `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_category` (`category`),
    KEY `idx_creator_id` (`creator_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='流程模板表';

-- ============================================================
-- 5. 模板步骤表
-- ============================================================
DROP TABLE IF EXISTS `template_step`;
CREATE TABLE `template_step` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `template_id` BIGINT       NOT NULL                COMMENT '所属模板ID',
    `sort_order`  INT          NOT NULL DEFAULT 0      COMMENT '排序序号',
    `title`       VARCHAR(100) NOT NULL                COMMENT '步骤标题',
    `description` VARCHAR(500) DEFAULT NULL             COMMENT '步骤说明',
    PRIMARY KEY (`id`),
    KEY `idx_template_id` (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='模板步骤表';

-- ============================================================
-- 6. 模板材料表
-- ============================================================
DROP TABLE IF EXISTS `template_material`;
CREATE TABLE `template_material` (
    `id`          BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `template_id` BIGINT      NOT NULL                COMMENT '所属模板ID',
    `name`        VARCHAR(50) NOT NULL                COMMENT '材料名称',
    PRIMARY KEY (`id`),
    KEY `idx_template_id` (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='模板材料表';

-- ============================================================
-- 7. 任务表
-- ============================================================
DROP TABLE IF EXISTS `task`;
CREATE TABLE `task` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `title`       VARCHAR(100) NOT NULL                COMMENT '任务标题',
    `category`    VARCHAR(20)  NOT NULL                COMMENT '业务模块：GOVERNMENT / LIFE / HEALTH / COMMUNITY',
    `plan_date`   DATE         NOT NULL                COMMENT '预计办理日期',
    `plan_time`   TIME         DEFAULT NULL             COMMENT '预计办理时间',
    `location`    VARCHAR(200) DEFAULT NULL             COMMENT '办理地点',
    `remark`      TEXT         DEFAULT NULL             COMMENT '备注',
    `status`      VARCHAR(20)  NOT NULL DEFAULT 'PENDING' COMMENT '状态：PENDING-待办 / IN_PROGRESS-进行中 / COMPLETED-已完成 / CANCELLED-已取消',
    `elderly_id`  BIGINT       NOT NULL                COMMENT '所属老人ID',
    `creator_id`  BIGINT       NOT NULL                COMMENT '创建人ID（老人自己或家属）',
    `template_id` BIGINT       DEFAULT NULL             COMMENT '关联模板ID',
    `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_elderly_id` (`elderly_id`),
    KEY `idx_creator_id` (`creator_id`),
    KEY `idx_status` (`status`),
    KEY `idx_plan_date` (`plan_date`),
    KEY `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='任务表';

-- ============================================================
-- 8. 任务步骤表
-- ============================================================
DROP TABLE IF EXISTS `task_step`;
CREATE TABLE `task_step` (
    `id`           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `task_id`      BIGINT       NOT NULL                COMMENT '所属任务ID',
    `sort_order`   INT          NOT NULL DEFAULT 0      COMMENT '排序序号',
    `title`        VARCHAR(100) NOT NULL                COMMENT '步骤标题',
    `description`  VARCHAR(500) DEFAULT NULL             COMMENT '步骤说明',
    `is_completed` TINYINT      NOT NULL DEFAULT 0      COMMENT '是否已完成：0-否 1-是',
    PRIMARY KEY (`id`),
    KEY `idx_task_id` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='任务步骤表';

-- ============================================================
-- 9. 材料清单表
-- ============================================================
DROP TABLE IF EXISTS `task_material`;
CREATE TABLE `task_material` (
    `id`         BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `task_id`    BIGINT      NOT NULL                COMMENT '所属任务ID',
    `name`       VARCHAR(50) NOT NULL                COMMENT '材料名称',
    `is_checked` TINYINT     NOT NULL DEFAULT 0      COMMENT '是否已确认准备：0-否 1-是',
    PRIMARY KEY (`id`),
    KEY `idx_task_id` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='材料清单表';

-- ============================================================
-- 10. 求助表
-- ============================================================
DROP TABLE IF EXISTS `help_request`;
CREATE TABLE `help_request` (
    `id`           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `elderly_id`   BIGINT       NOT NULL                COMMENT '发起人（老人）ID',
    `task_id`      BIGINT       DEFAULT NULL             COMMENT '关联任务ID',
    `description`  VARCHAR(500) DEFAULT NULL             COMMENT '问题描述',
    `location`     VARCHAR(200) DEFAULT NULL             COMMENT '当前位置',
    `phone`        VARCHAR(20)  NOT NULL                COMMENT '联系电话',
    `community`    VARCHAR(100) NOT NULL                COMMENT '所属社区',
    `status`       VARCHAR(20)  NOT NULL DEFAULT 'WAITING' COMMENT '状态：WAITING-待接单 / ACCEPTED-已接单 / IN_SERVICE-服务中 / COMPLETED-已完成 / CANCELLED-已取消',
    `volunteer_id` BIGINT       DEFAULT NULL             COMMENT '接单志愿者ID',
    `create_time`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '求助时间',
    `update_time`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_elderly_id` (`elderly_id`),
    KEY `idx_volunteer_id` (`volunteer_id`),
    KEY `idx_community` (`community`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='求助表';

-- ============================================================
-- 11. 服务记录表
-- ============================================================
DROP TABLE IF EXISTS `service_record`;
CREATE TABLE `service_record` (
    `id`              BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `help_request_id` BIGINT       NOT NULL                COMMENT '关联求助ID',
    `volunteer_id`    BIGINT       NOT NULL                COMMENT '志愿者ID',
    `service_type`    VARCHAR(20)  NOT NULL                COMMENT '服务方式：ONLINE-线上 / OFFLINE-线下',
    `duration`        INT          NOT NULL DEFAULT 0      COMMENT '服务时长（分钟）',
    `content`         VARCHAR(500) DEFAULT NULL             COMMENT '服务内容摘要',
    `points`          INT          NOT NULL DEFAULT 0      COMMENT '获得积分',
    `create_time`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
    PRIMARY KEY (`id`),
    KEY `idx_help_request_id` (`help_request_id`),
    KEY `idx_volunteer_id` (`volunteer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='服务记录表';

-- ============================================================
-- 12. 服务评价表
-- ============================================================
DROP TABLE IF EXISTS `service_review`;
CREATE TABLE `service_review` (
    `id`                BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `service_record_id` BIGINT       NOT NULL                COMMENT '关联服务记录ID',
    `reviewer_id`       BIGINT       NOT NULL                COMMENT '评价人ID（老人或家属）',
    `rating`            TINYINT      NOT NULL                COMMENT '评分：1-5星',
    `comment`           VARCHAR(500) DEFAULT NULL             COMMENT '评语',
    `create_time`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_service_record` (`service_record_id`),
    KEY `idx_reviewer_id` (`reviewer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='服务评价表';

-- ============================================================
-- 初始数据：预置管理员账号
-- ============================================================
INSERT INTO `user` (`openid`, `nickname`, `name`, `phone`, `community`, `invite_code`)
VALUES ('admin_default', '系统管理员', '管理员', '00000000000', '系统', NULL);

INSERT INTO `user_role` (`user_id`, `role`)
VALUES (1, 'ADMIN');

-- ============================================================
-- 初始数据：预置流程模板示例
-- ============================================================

-- 模板1：医院复诊流程
INSERT INTO `flow_template` (`name`, `category`, `creator_id`)
VALUES ('医院复诊流程', 'HEALTH', 1);

INSERT INTO `template_step` (`template_id`, `sort_order`, `title`, `description`) VALUES
(1, 1, '到医院门诊大厅', '找到自助机或挂号窗口'),
(1, 2, '挂号', '出示医保卡，选择科室和医生'),
(1, 3, '候诊', '去对应科室门口等叫号'),
(1, 4, '就诊', '进诊室，把上次病历和检查报告给医生看'),
(1, 5, '缴费取药', '拿处方去缴费窗口，再去药房取药');

INSERT INTO `template_material` (`template_id`, `name`) VALUES
(1, '身份证'),
(1, '医保卡'),
(1, '上次病历'),
(1, '上次检查报告'),
(1, '手机（医保码）');

-- 模板2：社保年度认证流程
INSERT INTO `flow_template` (`name`, `category`, `creator_id`)
VALUES ('社保年度认证流程', 'GOVERNMENT', 1);

INSERT INTO `template_step` (`template_id`, `sort_order`, `title`, `description`) VALUES
(2, 1, '打开手机微信', '找到微信图标，点击打开'),
(2, 2, '进入社保认证小程序', '在微信搜索栏输入"社保认证"或扫描社区提供的二维码'),
(2, 3, '实名认证', '输入姓名和身份证号码，进行人脸识别验证'),
(2, 4, '完成认证', '看到"认证成功"页面即可，截图保存');

INSERT INTO `template_material` (`template_id`, `name`) VALUES
(2, '身份证'),
(2, '手机'),
(2, '社保卡');

-- 模板3：水电费缴纳流程
INSERT INTO `flow_template` (`name`, `category`, `creator_id`)
VALUES ('水电费缴纳流程', 'LIFE', 1);

INSERT INTO `template_step` (`template_id`, `sort_order`, `title`, `description`) VALUES
(3, 1, '准备缴费信息', '找到水费/电费账单或户号'),
(3, 2, '前往缴费网点', '到附近银行或社区服务中心'),
(3, 3, '排队取号', '到了网点先取号排队'),
(3, 4, '告知缴费信息', '把户号和要缴的费用告诉工作人员'),
(3, 5, '缴费并保留凭证', '缴费后保留好收据');

INSERT INTO `template_material` (`template_id`, `name`) VALUES
(3, '水费/电费账单'),
(3, '户号'),
(3, '现金或银行卡'),
(3, '身份证');
