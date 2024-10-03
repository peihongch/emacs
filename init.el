;;; init.el --- initial configs for emacs -*- lexical-binding: t; -*-

;; Author: Peihong Chen <chph13420146901@gmail.com>
;; Maintainer: Peihong Chen <chph13420146901@gmail.com>
;; Version: 0.1
;; Package-Requires: ((emacs "29.0"))
;; Keywords: convenience, tools
;; URL: https://github.com/chph/emacs

;;; Commentary:

;;; Configs:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                            Emacs Packages Sources

(require 'package)
(setq package-archives '(("gnu"    . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(package-initialize) ;; You might already have this line

;;防止反复调用 package-refresh-contents 会影响加载速度
(when (not package-archive-contents)
  (package-refresh-contents))

(setq url-proxy-services
      '(("no_proxy" . "^\\(localhost\\|10.*\\)")
        ("http" . "127.0.0.1:7890")
        ("https" . "127.0.0.1:7890")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                  Pre-configs

(setq dired-use-ls-dired nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                 C/C++ Configs

;; 启用cc-mode和基本设置
(setq c-default-style "linux"         ;; 使用Linux风格
      c-basic-offset 4)                ;; 设置缩进为4个空格
(add-hook 'c-mode-hook
          (lambda ()
            (c-set-offset 'substatement-open 0)))  ;; 函数内部的大括号不额外缩进

;; 安装 company 补全插件
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
;; 优化 company 的延时与显示
(setq company-idle-delay 0.2)      ;; 延迟 0.2 秒显示补全
(setq company-minimum-prefix-length 1) ;; 输入一个字符就触发补全

;; 安装lsp-mode和ccls/clangd支持
(require 'lsp-mode)
(add-hook 'c-mode-hook #'lsp-deferred)
(setq lsp-prefer-capf t)  ;; 设置lsp使用capf进行补全
(setq lsp-clients-clangd-executable "/usr/local/opt/llvm/bin/clangd")  ;; 根据实际路径修改

;; 启用语法检查
(require 'flycheck)
(global-flycheck-mode t)

;; 安装C语言代码片段
(require 'yasnippet)
(yas-global-mode 1)

;; 启用 projectile 模式
(use-package projectile
  :ensure t
  :init
  ;; 默认启用 projectile-mode
  (projectile-mode +1)
  :bind (("C-c p f" . projectile-find-file)
         ("C-c p p" . projectile-switch-project)
         ("C-c p s s" . projectile-ag))
  :config
  ;; 设置缓存和索引目录
  (setq projectile-cache-file (expand-file-name ".projectile-cache" user-emacs-directory))
  (setq projectile-indexing-method 'hybrid)
  ;; 忽略一些文件类型
  (setq projectile-globally-ignored-files '("TAGS" "*.o" "*.elc"))
  ;; 配置使用 ivy
  (setq projectile-completion-system 'ivy)
  ;; 设置项目搜索方式
  (setq projectile-enable-caching t)
  ;; 设置默认项目搜索工具
  (setq projectile-project-search-path '("~/GitHub" "~/GitLab" "~/Documents")))
;; 配合 helm 使用 projectile
  (use-package helm-projectile
  :ensure t
  :config
  (helm-projectile-on))

;; 快捷键提示
(require 'which-key)
(which-key-mode)

;; gdb集成
(setq gdb-many-windows t)          ;; 启用多个窗口显示
(setq gdb-show-main t)             ;; 打开gdb时显示主函数

;; 调试适配器协议
(require 'dap-mode)
(require 'dap-lldb)  ;; 使用lldb后端调试C/C++
(dap-mode 1)
(dap-ui-mode 1)

;; 设置 clang-format 路径，并绑定快捷键格式化代码
(require 'clang-format)
(global-set-key (kbd "C-c f") 'clang-format-buffer)
;; 或者使用默认的缩进格式化命令
(global-set-key (kbd "C-c i") 'indent-region)

;; 代码跳转、符号搜索等操作
(require 'ggtags)
(add-hook 'c-mode-common-hook
          (lambda ()
            (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
              (ggtags-mode 1))))

;; 文档查看
(add-hook 'c-mode-hook 'eldoc-mode)

;; 启用行号显示和语法高亮
(global-linum-mode 1)                ;; 显示行号
(global-font-lock-mode t)            ;; 语法高亮

;; 便捷文件与缓冲区切换
(ido-mode 1)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)

;; 更好的折叠支持
(add-hook 'c-mode-hook 'hs-minor-mode)  ;; 启用代码折叠
(global-set-key (kbd "C-c @ C-c") 'hs-toggle-hiding)  ;; 绑定代码折叠快捷键

;; Dirvish文件管理器
(use-package dirvish
  :ensure t
  :init
  ;; 在所有 Dired 缓冲区中启用 Dirvish
  (dirvish-override-dired-mode)
  :custom
  ;; 让 Dirvish 自动加载当前目录下的所有文件
  (dirvish-cache-dir (expand-file-name "dirvish" user-emacs-directory))
  ;; 显示图标
  (dirvish-use-header-line t)
  (dirvish-use-mode-line nil)
  :config
  ;; 设置 Dirvish 的快捷键
  (setq dirvish-mode-line-format
        '(:left (sort file-size) :right (omit yank index)))
  (setq dirvish-attributes '(all-the-icons file-size collapse git-msg))
  (setq dirvish-side-width 30)
  ;; 启用一些扩展
  (dirvish-peek-mode) ;; 启用预览功能
  (dirvish-side-follow-mode)) ;; 启用边侧文件管理器模式
;; 自定义快捷键
(with-eval-after-load 'dirvish
  (define-key dirvish-mode-map (kbd "C-c C-c") 'dirvish-collapse)
  (define-key dirvish-mode-map (kbd "C-c C-r") 'dirvish-refresh)
  (define-key dirvish-mode-map (kbd "C-c d") 'dirvish-side))
;; Git 集成
(setq dirvish-attributes '(all-the-icons git-msg))
;; 视图布局，可以设置显示哪些文件属性（如大小、创建时间、文件权限等）
(setq dirvish-mode-line-format
      '(:left (sort file-size) :right (omit yank index)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                  主题/颜色

(use-package solarized-theme
  :ensure t
  :config
  (load-theme 'solarized-dark t))

;; 确保使用适当的图标包
(use-package all-the-icons
  :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 关闭工具栏
(tool-bar-mode -1)

;; 关闭文件滑动控件
(scroll-bar-mode -1)

;; 更改光标样式
(global-linum-mode 1)

(setq cursor-type 'bar)

(icomplete-mode 1)

;; 快速打开配置文件
(defun open-init-file()
  (interactive)
  (find-file "~/.emacs.d/init.el"))

;; 将open-init-file绑定到<f2>键上
(global-set-key (kbd "<f2>") 'open-init-file)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(dirvish-magit dirvish-project dirvish all-the-icons doom-modeline doom-themes ggtags clang-format dap-mode helm-projectile helm which-key projectile yasnippet flycheck gnu-elpa-keyring-update lsp-mode company use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

