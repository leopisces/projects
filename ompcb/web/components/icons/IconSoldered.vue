<template>
  <!-- 「焊接到板」语义：用板上的两个焊盘 + 引脚弧线表达。
       与 IconRequired 同外框尺寸 1.5，与 IconMatched/IconUnmatched 同一笔触语言 -->
  <svg viewBox="0 0 16 16" width="16" height="16" fill="none" stroke="currentColor"
       stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"
       xmlns="http://www.w3.org/2000/svg">
    <rect x="2" y="2.5" width="12" height="11" rx="0.5" />
    <circle cx="5.5" cy="6" r="0.9" fill="currentColor" stroke="none" />
    <circle cx="10.5" cy="6" r="0.9" fill="currentColor" stroke="none" />
    <line x1="5.5" y1="6.9" x2="5.5" y2="9.5" />
    <line x1="10.5" y1="6.9" x2="10.5" y2="9.5" />
    <line x1="4" y1="9.5" x2="12" y2="9.5" />
  </svg>
</template>
