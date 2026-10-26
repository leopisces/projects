// 毁坏性操作的二次确认。
//
// 为什么要两步：删产品会连带整份 BOM，删元件会连带全部出入库流水，
// replace 导入会清空现有数据 —— 这些都不可恢复，误点一次就没了。
// 单个 confirm 点惯了会变成肌肉记忆，第二步换掉按钮文案与措辞，
// 强制多读一遍再点。
//
// 用户取消（任一步）都当作放弃，返回 false 而不是抛异常，
// 调用方就不用把业务逻辑包在 try/catch 里靠异常控流。
import { ElMessageBox } from 'element-plus';

/**
 * 两步确认。任一步取消即返回 false。
 * @param {object} opts
 * @param {string} opts.title        弹窗标题（两步共用）
 * @param {string} opts.firstMessage 第一步：说清这次操作会影响什么
 * @param {string} opts.firstConfirm 第一步确认按钮文案
 * @param {string} [opts.secondMessage] 第二步：强调不可恢复；省略则自动生成
 * @param {string} [opts.secondConfirm='确认，不可恢复'] 第二步确认按钮文案
 * @returns {Promise<boolean>}
 */
export async function confirmDestructive({
  title,
  firstMessage,
  firstConfirm,
  secondMessage,
  secondConfirm = '确认，不可恢复',
} = {}) {
  const base = {
    type: 'warning',
    cancelButtonText: '取消',
    // 点遮罩不算确认也不算误触，直接当取消处理
    closeOnClickModal: false,
    closeOnPressEscape: true,
  };

  try {
    await ElMessageBox.confirm(firstMessage, title, {
      ...base,
      confirmButtonText: firstConfirm,
    });
  } catch {
    return false;
  }

  try {
    await ElMessageBox.confirm(
      secondMessage ?? '此操作不可恢复，数据删除后无法找回。确定要继续吗？',
      `${title} · 再次确认`,
      {
        ...base,
        type: 'error',
        confirmButtonText: secondConfirm,
        confirmButtonClass: 'el-button--danger',
      }
    );
  } catch {
    return false;
  }

  return true;
}
