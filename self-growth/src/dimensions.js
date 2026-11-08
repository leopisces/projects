/** 五个成长维度（体系设计 §2）——一次记录只归一个主维度 */
export const DIMENSIONS = [
  {
    id: 'body',
    icon: '🫀',
    name: '身体',
    color: '#f85149',
    desc: '运动、睡眠、饮食、体检、康复',
    keywords: ['跑', '健身', '运动', '锻炼', '睡', '早睡', '早起', '体检', '拉伸', '游泳', '骑车', '走路', '散步', '吃饭', '饮食', '康复', '瑜伽', '力量'],
  },
  {
    id: 'mind',
    icon: '🧠',
    name: '心智',
    color: '#58a6ff',
    desc: '学习、阅读、思考、技能练习、理解',
    keywords: ['学', '读', '看', '研究', '理解', '懂', '复习', '课程', '论文', '笔记', '思考', '琢磨', '练习', '刷题', '数学', '英语', '算法'],
  },
  {
    id: 'heart',
    icon: '🫶',
    name: '情绪关系',
    color: '#db61a2',
    desc: '情绪调节、家人朋友、社交、陪伴与求助',
    keywords: ['朋友', '家人', '妈', '爸', '陪', '聊', '倾诉', '道歉', '和解', '情绪', '焦虑', '难过', '开心', '沟通', '感谢', '帮忙', '聚会', '志愿'],
  },
  {
    id: 'craft',
    icon: '🔨',
    name: '创造产出',
    color: '#3fb950',
    desc: '写代码、写作、做出作品、解决真实问题',
    keywords: ['写', '做', '开发', '上线', '发布', '提交', '完成', '产出', '作品', '文章', '项目', '修复', '重构', '搞定', '解决问题', '画', '剪辑', '录制'],
  },
  {
    id: 'order',
    icon: '🧭',
    name: '秩序',
    color: '#d29922',
    desc: '环境、习惯、时间、财务、流程整理',
    keywords: ['整理', '收拾', '归档', '记账', '计划', '安排', '日程', '清单', '清理', '备份', '分类', '报销', '预算', '流程', 'todo'],
  },
]

export const dimById = (id) => DIMENSIONS.find((d) => d.id === id) || DIMENSIONS[1]

/** 挑战等级轴（体系设计 §2.3） */
export const CHALLENGE_LEVELS = [
  { value: 1.0, label: '舒适区内' },
  { value: 1.3, label: '略超舒适区' },
  { value: 1.6, label: '明显吃力' },
]

export function challengeLabel(v) {
  const hit = CHALLENGE_LEVELS.find((c) => Math.abs(c.value - v) < 0.01)
  return hit ? hit.label : `×${v}`
}

/** 基础分强度档位（体系设计 §3.1），用于界面/说明展示 */
export const SCORE_BANDS = [
  { min: 1, max: 4, label: '微小' },
  { min: 5, max: 9, label: '标准' },
  { min: 10, max: 14, label: '扎实' },
  { min: 15, max: 20, label: '里程碑' },
]

export function bandOf(points) {
  return SCORE_BANDS.find((b) => points >= b.min && points <= b.max) || SCORE_BANDS[1]
}
