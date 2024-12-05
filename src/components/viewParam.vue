<template>
    <ul>
        <el-form :model="node.data" ref="form" abel-width="auto">
            <li>
                <el-row :gutter="2" style="padding-bottom: 10px;">
                    <el-col :span="10">
                        <!-- show group key -->
                        <div v-if="node.data.type === 'Group'">
                            <el-button text @click="node.data.hide = !node.data.hide" style="margin: 0; padding: 5px; ">
                                <svg v-if="node.data.hide" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                                    <path
                                        d="m14.707 12.707-4 4a1 1 0 0 1-1.414-1.414L12.586 12 9.293 8.707a1 1 0 1 1 1.414-1.414l4 4a1 1 0 0 1 0 1.414z" />
                                </svg>
                                <svg v-if="!node.data.hide" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                                    <path
                                        d="M12 15a1 1 0 0 1-.707-.293l-4-4a1 1 0 1 1 1.414-1.414L12 12.586l3.293-3.293a1 1 0 0 1 1.414 1.414l-4 4A1 1 0 0 1 12 15z" />
                                </svg>
                            </el-button>

                            <span>{{ node.data.key }}</span>
                        </div>

                        <!-- show param key -->
                        <div v-if="node.data.type === 'Param'"
                            style="word-wrap: break-word; overflow-wrap: break-word;">
                            <span>{{ node.data.key }}</span>
                        </div>
                    </el-col>

                    <!-- show the value -->
                    <el-col :span="14">
                        <div v-if="node.data.value" class="value-show">
                            {{ node.data.value }}
                        </div>
                    </el-col>
                </el-row>
                <viewParam v-if="!node.data.hide" v-for="nodeChildren in node.children" :node="nodeChildren"
                    :children="node.children" :globalFold="globalFold" />
            </li>
        </el-form>
    </ul>
</template>

<script>

export default {
    props: {
        node: {
            type: Object,
            default: {}
        },
        children: {
            type: Array,
            default: []
        },
        globalFold: {
            type: Boolean,
            default: false
        }
    },
    watch: {
        globalFold(newVal) {
            if (newVal !== null) {
                this.node.data.hide = newVal;
                this.syncChildrenFold(this.node.children, newVal);
            }
        },
    },
    methods: {
        syncChildrenFold(children, fold) {
            if (!children || children.length === 0) return;
            children.forEach((child) => {
                child.data.hide = fold;
                if (child.children) {
                    this.syncChildrenFold(child.children, fold);
                }
            });
        },
    }
}
</script>

<style scoped>
svg {
    height: 1em;
    width: 1em;
    color: black;
}

.value-show {
    overflow-wrap: break-word;
    /* border: 1px solid #ccc; */
    background-color: #F2F3F5;
}
</style>