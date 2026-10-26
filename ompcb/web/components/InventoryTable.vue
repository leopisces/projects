<template>
  <el-table
    ref="tableRef"
    v-loading="loading"
    :data="rows"
    border
    stripe
    size="small"
    height="100%"
    row-key="id"
    :row-class-name="rowClassName"
    @sort-change="(payload) => emit('sort-change', payload)"
    @selection-change="(val) => emit('selection-change', val)"
    empty-text="暂无库存记录"
  >
    <template #empty>
      <div class="inv-empty">
        <EmptyBoard />
        <div class="inv-empty-text">暂无库存记录</div>
      </div>
    </template>
    <!-- 勾选列：供批量删除用。reserve-selection 让翻页/重取后已勾选的行保持选中，
         配合 row-key 生效——否则改个筛选条件勾选就全丢了。 -->
    <el-table-column type="selection" width="40" reserve-selection />
    <el-table-column
      prop="name" label="名称" min-width="140" sortable="custom" class-name="col-truncate"
      show-overflow-tooltip
    >
      <template #default="{ row }">
        <span :title="row.name || ''">{{ row.name || '—' }}</span>
      </template>
    </el-table-column>
    <el-table-column
      prop="package" label="封装" min-width="140" sortable="custom"
      class-name="col-truncate" show-overflow-tooltip
    >
      <template #default="{ row }">
        <span :title="row.package || ''">{{ row.package || '—' }}</span>
      </template>
    </el-table-column>
    <el-table-column
      prop="mfr_pn" label="制造商料号" min-width="180" sortable="custom"
      class-name="col-truncate col-pn" show-overflow-tooltip
    >
      <template #default="{ row }">
        <span :title="row.mfr_pn || ''">{{ row.mfr_pn || '—' }}</span>
      </template>
    </el-table-column>
    <el-table-column
      prop="mfr" label="制造商" min-width="150" sortable="custom"
      class-name="col-truncate" show-overflow-tooltip
    >
      <template #default="{ row }">
        <span :title="row.mfr || ''">{{ row.mfr || '—' }}</span>
      </template>
    </el-table-column>
    <el-table-column
      prop="supplier" label="供应商" width="100" sortable="custom"
      class-name="col-truncate" show-overflow-tooltip
    >
      <template #default="{ row }">
        <span :title="row.supplier || ''">{{ row.supplier || '—' }}</span>
      </template>
    </el-table-column>
    <el-table-column
      prop="supplier_pn" label="供应商料号" min-width="120" sortable="custom"
      class-name="col-truncate col-pn" show-overflow-tooltip
    >
      <template #default="{ row }">
        <span :title="row.supplier_pn || ''">{{ row.supplier_pn || '—' }}</span>
      </template>
    </el-table-column>
    <el-table-column
      prop="status" label="状态" width="110" align="center" sortable="custom"
    >
      <template #default="{ row }">
        <el-tag :type="statusTagType(row.status)" size="small" class="status-tag" effect="light">
          {{ row.status || '—' }}
        </el-tag>
      </template>
    </el-table-column>
    <el-table-column
      prop="stock" label="库存" width="90" align="right" header-align="right"
      sortable="custom" class-name="col-num"
    >
      <template #default="{ row }">
        <span :class="{ 'stock-zero': Number(row.stock) === 0 }">{{ row.stock }}</span>
      </template>
    </el-table-column>
    <el-table-column
      prop="location" label="位置" min-width="110" sortable="custom"
      class-name="col-truncate" show-overflow-tooltip
    >
      <template #default="{ row }">
        <span :title="row.location || ''">{{ row.location || '—' }}</span>
      </template>
    </el-table-column>
    <el-table-column
      prop="remark" label="备注" min-width="120"
      class-name="col-truncate" show-overflow-tooltip
    >
      <template #default="{ row }">
        <span :title="row.remark || ''">{{ row.remark || '—' }}</span>
      </template>
    </el-table-column>
    <el-table-column label="操作" width="210" fixed="right" align="center">
      <template #default="{ row }">
        <div class="op-cell">
          <el-button link type="success" size="small" @click="emit('move', row, '入库')">入库</el-button>
          <el-button link type="warning" size="small" @click="emit('move', row, '出库')">出库</el-button>
          <el-button link size="small" @click="emit('logs', row)">流水</el-button>
          <el-button link type="primary" size="small" @click="emit('edit', row)">编辑</el-button>
          <el-button link type="danger" size="small" @click="emit('delete', row)">删除</el-button>
        </div>
      </template>
    </el-table-column>
  </el-table>
</template>

<script setup>
import { ref } from 'vue';
import EmptyBoard from './EmptyBoard.vue';

defineProps({
  rows: { type: Array, required: true },
  loading: { type: Boolean, default: false },
});

const emit = defineEmits(['sort-change', 'edit', 'delete', 'move', 'logs', 'selection-change']);

const tableRef = ref(null);

// 删除完成后父组件要清掉勾选，否则残留的行已经不存在了。
// reserve-selection 会跨重取保留选中，所以必须显式清。
defineExpose({
  clearSelection: () => tableRef.value?.clearSelection?.(),
});

// 状态只有两种：正常（绿=安全）/ 缺货（红=要处理）
function statusTagType(status) {
  return status === '缺货' ? 'danger' : 'success';
}

// 零库存行给一个淡色提示，和 BOM 表的缺料行视觉语言保持一致
function rowClassName({ row }) {
  if (Number(row?.stock) === 0) return 'row-shortage';
  return '';
}
</script>

<style scoped>
/* 零库存用 danger 红，与 BOM 缺料共用同一种「要处理」颜色；
   行底色已经由 .row-shortage 提供 --c-warn-soft，数字本身走红才能在视觉上和缺料对得上 */
.stock-zero {
  color: var(--c-danger);
  font-weight: 600;
}

.inv-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  padding: 28px 0;
}
.inv-empty-text {
  font-size: var(--fs-table);
  color: var(--c-text-3);
}
</style>
