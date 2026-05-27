# 银龄配办小程序

> 面向老年人的生活事务辅助与社区互助移动端 H5 应用

![Vue](https://img.shields.io/badge/Vue-3.4+-brightgreen.svg)
![Vite](https://img.shields.io/badge/Vite-5.4+-orange.svg)
![Vant](https://img.shields.io/badge/Vant-4.9+-blue.svg)

## 📖 项目简介

**银龄配办**是一款聚焦老年人日常办事场景的精细化 H5 应用，提供从任务提醒、材料准备、步骤指导到志愿者协助的全流程配套服务。

### 核心理念

```
要办事 → 提醒你 → 告诉你带啥 → 教你怎么走 → 卡住了帮你叫人 → 办完了打勾
```

### 产品定位

- **不是**大而全的养老平台
- **而是**精准聚焦"老人办事"场景的精细化工具
- 移动端 H5 网页，适配移动端分辨率，提供类 App 体验

## ✨ 核心功能

### 1. 用户系统
- ✅ 手机号/账号密码注册登录
- ✅ 四种角色：老人、家属、志愿者、管理员
- ✅ 多角色支持（一个用户可同时拥有多个角色）

### 2. 家属绑定
- ✅ 邀请码方式绑定老人
- ✅ 支持多对多关系（一家属绑多老人，一老人被多家属绑定）

### 3. 任务管理
- ✅ 四大业务分类：政务帮办、生活协助、健康支持、社区连接
- ✅ 任务状态流转：待办 → 进行中 → 已完成/已取消
- ✅ 家属代建任务、查看进度

### 4. 办事步骤与材料
- ✅ 步骤管理：创建、展示、逐步勾选
- ✅ 材料清单：创建、展示、勾选确认

### 5. 求助与志愿服务
- ✅ 老人一键求助
- ✅ 志愿者查看求助、接单
- ✅ 服务记录（时长、方式、内容）

### 6. 适老化设计
- ✅ 老人端极简界面
- ✅ 大字体、高对比度、简洁操作

## 🛠️ 技术栈

### 前端
- **框架**: Vue 3.4+
- **构建工具**: Vite 5.4+
- **路由**: Vue Router 4.3+
- **状态管理**: Pinia 2.1+
- **UI 组件库**: Vant 4.9+
- **HTTP 客户端**: Axios 1.7+
- **按需引入**: unplugin-vue-components

### 后端（另仓库）
- Spring Boot
- MySQL

## 📁 项目结构

```
senior/
├── doc/                      # 文档目录
│   ├── schema.sql           # 数据库脚本
│   ├── 银龄配办小程序-接口文档.md
│   └── 银龄配办小程序-需求文档.md
├── src/
│   ├── api/                 # API 接口封装
│   │   ├── admin.js        # 管理员相关接口
│   │   ├── binding.js      # 绑定相关接口
│   │   ├── help.js         # 求助相关接口
│   │   ├── request.js      # Axios 请求封装
│   │   ├── service.js      # 服务相关接口
│   │   ├── task.js         # 任务相关接口
│   │   ├── taskMaterial.js # 任务材料接口
│   │   ├── taskStep.js     # 任务步骤接口
│   │   ├── template.js     # 模板相关接口
│   │   └── user.js         # 用户相关接口
│   ├── components/          # 公共组件
│   │   ├── ElderlyLayout.vue    # 老人端布局
│   │   ├── EmptyState.vue       # 空状态组件
│   │   ├── HelpCard.vue         # 求助卡片
│   │   ├── MaterialList.vue     # 材料列表
│   │   ├── StandardLayout.vue   # 标准布局
│   │   ├── StepList.vue         # 步骤列表
│   │   └── TaskCard.vue         # 任务卡片
│   ├── router/              # 路由配置
│   │   └── index.js
│   ├── stores/              # Pinia 状态管理
│   │   └── user.js         # 用户状态
│   ├── styles/              # 全局样式
│   │   └── global.css
│   ├── utils/               # 工具函数
│   │   └── constants.js    # 常量定义
│   ├── views/               # 页面视图
│   │   ├── admin/          # 管理员页面
│   │   ├── common/         # 公共页面（登录、注册）
│   │   ├── elderly/        # 老人端页面
│   │   ├── family/         # 家属端页面
│   │   └── volunteer/      # 志愿者端页面
│   ├── App.vue             # 根组件
│   └── main.js             # 入口文件
├── .gitignore              # Git 忽略配置
├── index.html              # HTML 模板
├── package.json            # 项目依赖
├── vite.config.js          # Vite 配置
└── README.md               # 项目说明
```

## 🚀 快速开始

### 环境要求

- Node.js >= 18.x
- npm >= 9.x 或 yarn >= 1.22.x

### 安装依赖

```bash
npm install
```

### 开发模式

```bash
npm run dev
```

访问 http://localhost:5175

### 生产构建

```bash
npm run build
```

构建产物将输出到 `dist/` 目录

### 预览构建结果

```bash
npm run preview
```

## ⚙️ 配置说明

### 代理配置

项目已配置开发服务器代理，在 `vite.config.js` 中：

```javascript
server: {
  port: 5175,
  proxy: {
    '/api': {
      target: 'https://frp-six.com:63466',
      changeOrigin: true,
      secure: false
    }
  }
}
```

如需修改后端接口地址，请编辑此配置。

### 环境变量

创建 `.env` 文件（不会被提交到 Git）：

```env
VITE_API_BASE_URL=https://your-api-domain.com
```

## 📅 版本历史

- **v2.0** (2026年5月) - 当前版本

## 📄 许可证

本项目为课程项目，仅供学习使用。

## 📞 联系方式

如有问题或建议，请联系项目组成员。

---

**温馨提示**: 本项目需要配合后端服务使用，请确保后端服务已启动并正确配置接口地址。
