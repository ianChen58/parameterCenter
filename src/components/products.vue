<template>
    <div>
        <el-row>
            <el-col :span="6">
                <h1>Product List</h1>
            </el-col>
            <el-col :span="18" style="margin: 25px 0 10px;">
                <div style="display: flex; align-items: center;">
                    <el-select v-model="selectedInstance" placeholder="实例" style="width: 240px" filterable
                        @change="loadDatabases">
                        <el-option v-for="item in instances" :key="item.id" :label="item.instance_name"
                            :value="item.instance_name" />
                    </el-select>
                    <el-select v-model="selectedDatabase" placeholder="数据库" style="width: 240px" filterable
                        @change="chooseDatabase">
                        <el-option v-for="item in databases" :key="item" :label="item" :value="item" />
                    </el-select>
                </div>
            </el-col>
        </el-row>

        <table>
            <thead>
                <tr>
                    <th @click="sort('tenantId')">Tenant Id</th>
                    <th @click="sort('entityId')">Entity Id</th>
                    <th @click="sort('productCode')">Product Code
                        <span v-if="sortKey === 'productCode'">{{ sortOrder === 1 ? '▲' : '▼' }}</span>
                    </th>
                    <th @click="sort('templateId')">Template ID
                        <span v-if="sortKey === 'templateId'">{{ sortOrder === 1 ? '▲' : '▼' }}</span>
                    </th>
                    <th @click="sort('productId')">Product ID
                        <span v-if="sortKey === 'productId'">{{ sortOrder === 1 ? '▲' : '▼' }}</span>
                    </th>
                    <th @click="sort('productType')">Product Type
                        <span v-if="sortKey === 'productType'">{{ sortOrder === 1 ? '▲' : '▼' }}</span>
                    </th>
                    <th @click="sort('productName')">Product Name
                        <span v-if="sortKey === 'productName'">{{ sortOrder === 1 ? '▲' : '▼' }}</span>
                    </th>
                    <th @click="sort('configurationGroup')">Configuration Group
                        <span v-if="sortKey === 'configurationGroup'">{{ sortOrder === 1 ? '▲' : '▼' }}</span>
                    </th>
                    <th>View</th>
                    <th>Duplicate</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="(item, index) in sortedProducts" :key="index">
                    <td>{{ item.tenantId }}</td>
                    <td>{{ item.entityId }}</td>
                    <td>{{ item.productCode }}</td>
                    <td>{{ item.templateId }}</td>
                    <td>{{ item.productId }}</td>
                    <td>{{ item.productType }}</td>
                    <td>{{ item.productName }}</td>
                    <td>{{ item.configurationGroup }}</td>
                    <td>
                        <button @click="viewProduct(item)">View</button>
                    </td>
                    <td>
                        <button @click="duplicateProduct(item)">Duplicate</button>
                    </td>
                </tr>
            </tbody>
        </table>
        <br>

        <el-divider />

        <h1>System Parameter</h1>
        <table>
            <thead>
                <tr>
                    <th>Param Key</th>
                    <th>Description</th>
                    <th>Product Code</th>
                    <th>Module</th>
                    <th>Value Type</th>
                    <th>Value</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="item in sysParam">
                    <td>{{ item.paramKey }}</td>
                    <td>
                        <textarea v-if="item.paramDesc && item.paramDesc.length > 50" readonly rows="3"
                            style="width: 100%;">{{ item.paramDesc }}
                        </textarea>
                        <span v-else>{{ item.paramDesc }}</span>
                    </td>
                    <td>{{ item.productCode }}</td>
                    <td>{{ item.module }}</td>
                    <td>{{ item.paramValueType }}</td>
                    <td>
                        <textarea v-if="item.paramValue && item.paramValue.length > 50" readonly rows="3"
                            style="width: 100%;">{{ item.paramValue }}
                        </textarea>
                        <span v-else>{{ item.paramValue }}</span>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</template>

<script>
import { useProductStore } from '@/store/productStore';
import axios from 'axios';

export default {
    data() {
        return {
            selectedInstance: null,
            selectedDatabase: null,
            instances: [],
            databases: [],
            sysParam: [],
            paramList: [],
            products: [],
            sortKey: '',
            sortOrder: 1, // 排序顺序，1 表示升序，-1 表示降序
        };
    },
    computed: {
        sortedProducts() {
            if (!this.sortKey) {
                return this.products;
            }
            return [...this.products].sort((a, b) => {
                const aValue = a[this.sortKey];
                const bValue = b[this.sortKey];
                if (aValue < bValue) return -1 * this.sortOrder;
                if (aValue > bValue) return 1 * this.sortOrder;
                return 0;
            });
        },
    },
    mounted() {
        const productStore = useProductStore();
        this.userAllInstances()
        this.selectedInstance = productStore.instance || '';
        this.selectedDatabase = productStore.database || '';
        if (this.selectedInstance) {
            this.instanceResources();
        }
        // 在组件挂载后，检查是否有实例和数据库，并加载数据和参数
        if (this.selectedInstance && this.selectedDatabase) {
            this.fetchDataAndParams();
        }
    },
    methods: {
        sort(key) {
            if (this.sortKey === key) {
                this.sortOrder *= -1; // 切换升序或降序
            } else {
                this.sortKey = key;
                this.sortOrder = 1; // 默认升序
            }
        },
        async fetchDataAndParams() {
            try {
                await Promise.all([this.fetchData(), this.fetchParameter()]);
                this.findSystemParams();
            } catch (error) {
                console.error("Error fetching data and parameters:", error);
            }
        },
        //onchange database 后触发的方法
        chooseDatabase() {
            const productStore = useProductStore();
            productStore.setDatabase(this.selectedDatabase);
            this.fetchDataAndParams()
        },
        //onchange instance 后触发的方法
        async loadDatabases() {
            const productStore = useProductStore();
            // 当 selectedInstance 变化时，重新加载数据库列表
            if (this.selectedInstance) {
                productStore.setInstance(this.selectedInstance);
                await this.instanceResources();
                //清空products和sysParam
                this.products = [];
                this.sysParam = [];
                this.selectedDatabase = '';
                productStore.setDatabase(this.selectedDatabase);
            }
        },
        async instanceResources() {
            // try {
            //     const url = '/instance/instance_resource/';
            //     const response = await axios.get(
            //         url,
            //         {
            //             params: {
            //                 instance_name: this.selectedInstance,
            //                 resource_type: 'database',
            //             },
            //             headers: {
            //                 'Content-Type': 'application/json',
            //             }
            //         }
            //     );
            //     if (response.data && response.data.data) {
            //         this.databases = response.data.data.filter(item => item.startsWith('cif'));
            //     }
            // } catch (error) {
            //     console.error("Error fetching data:", error);
            // }
            this.databases = [
                "cifA1",
                "cifA2",
                "cifB1",
                "cifB2",
                "cifG1",
                "cifShadow",
            ]
        },
        async userAllInstances() {
            // try {
            //     const url = '/group/user_all_instances/';
            //     const response = await axios.get(
            //         url,
            //         {
            //             params: {
            //                 'tag_codes[]': 'can_read',
            //             },
            //             headers: {
            //                 'Content-Type': 'application/json',
            //             }
            //         }
            //     );
            //     if (response.data && response.data.data) {
            //         this.instances = response.data.data;
            //     }
            // } catch (error) {
            //     console.error("Error fetching data:", error);
            // }
            this.instances = [
                {
                    "id": 30,
                    "type": "master",
                    "db_type": "mysql",
                    "instance_name": "qa-aurora-cif1"
                },
                {
                    "id": 49,
                    "type": "master",
                    "db_type": "mysql",
                    "instance_name": "qa-aurora-cif2"
                },
                {
                    "id": 10,
                    "type": "master",
                    "db_type": "mysql",
                    "instance_name": "stable-dev"
                },
            ]
        },
        async fetchData() {
            // 模拟从后端获取数据的逻辑，这里使用模拟数据，实际应用中应从后端获取
            this.products =
                [
                    {
                        "id": 1,
                        "tenantId": "STMXFINCORE0",
                        "entityId": "MXCC20220000",
                        "createTimeLocal": "2022-12-28 00:54:37",
                        "createTimeUtc": "2022-12-28 06:54:37",
                        "updateTimeLocal": "2022-12-28 00:54:37",
                        "updateTimeUtc": "2022-12-28 06:54:37",
                        "templateId": "STCTP0001",
                        "productId": "1004",
                        "productCode": "STC001",
                        "productSubCode": null,
                        "productType": "CREDIT",
                        "productName": null,
                        "configurationGroup": "stori_product_configuration"
                    },
                    {
                        "id": 21,
                        "tenantId": "STMXFINCORE0",
                        "entityId": "MXCC20220000",
                        "createTimeLocal": "2023-11-14 07:19:53",
                        "createTimeUtc": "2023-11-14 13:19:53",
                        "updateTimeLocal": "2023-11-14 07:19:53",
                        "updateTimeUtc": "2023-11-14 13:19:53",
                        "templateId": "STCTP0002",
                        "productId": "1005",
                        "productCode": "STC002",
                        "productSubCode": null,
                        "productType": "CREDIT",
                        "productName": null,
                        "configurationGroup": "stori_product_configuration_x"
                    },
                    {
                        "id": 25,
                        "tenantId": "STMXFINCORE0",
                        "entityId": "MXCC20220000",
                        "createTimeLocal": "2024-04-18 07:51:44",
                        "createTimeUtc": "2024-04-18 13:51:44",
                        "updateTimeLocal": "2024-04-18 07:51:44",
                        "updateTimeUtc": "2024-04-18 13:51:44",
                        "templateId": "STCTP0003",
                        "productId": "1006",
                        "productCode": "STC003",
                        "productSubCode": null,
                        "productType": "CREDIT",
                        "productName": null,
                        "configurationGroup": "stori_product_configuration_s"
                    },
                    {
                        "id": 26,
                        "tenantId": "STMXFINCORE0",
                        "entityId": "MXCC20220000",
                        "createTimeLocal": "2024-07-18 21:53:14",
                        "createTimeUtc": "2024-07-19 03:53:14",
                        "updateTimeLocal": "2024-07-18 21:53:14",
                        "updateTimeUtc": "2024-07-19 03:53:14",
                        "templateId": "STCTP0004",
                        "productId": "2001",
                        "productCode": "STC004",
                        "productSubCode": null,
                        "productType": "CREDIT",
                        "productName": null,
                        "configurationGroup": "stori_product_configuration_sc_card"
                    },
                    {
                        "id": 30,
                        "tenantId": "STMXFINCORE0",
                        "entityId": "MXCC20220000",
                        "createTimeLocal": "2024-11-20 03:55:06",
                        "createTimeUtc": "2024-11-20 09:55:06",
                        "updateTimeLocal": "2024-11-20 03:55:06",
                        "updateTimeUtc": "2024-11-20 09:55:06",
                        "templateId": "STCTP0101",
                        "productId": "7001",
                        "productCode": "STC101",
                        "productSubCode": null,
                        "productType": "CREDIT",
                        "productName": null,
                        "configurationGroup": "stori_product_config_atlas_card"
                    },
                    {
                        "id": 31,
                        "tenantId": "STMXFINCORE0",
                        "entityId": "MXCC20220000",
                        "createTimeLocal": "2024-11-20 03:55:06",
                        "createTimeUtc": "2024-11-20 09:55:06",
                        "updateTimeLocal": "2024-11-20 03:55:06",
                        "updateTimeUtc": "2024-11-20 09:55:06",
                        "templateId": "STCTP0102",
                        "productId": "7002",
                        "productCode": "STC102",
                        "productSubCode": null,
                        "productType": "CREDIT",
                        "productName": null,
                        "configurationGroup": "stori_product_config_santos_card"
                    }
                ]
        },
        async fetchParameter() {
            // try {
            //     const url = '/api/product/allParameter';
            //     const response = await axios.get(
            //         url,
            //         {
            //             params: {
            //                 instance: this.selectedInstance,
            //                 database: this.selectedDatabase,
            //             },
            //             headers: {
            //                 'Content-Type': 'application/json',
            //             }
            //         }
            //     );
            //     if (response.data && response.data.data) {
            //         this.paramList = response.data.data;
            //     }
            // } catch (error) {
            //     console.error("Error fetching data:", error);
            // }
            this.paramList = [
                {
                    "id": 1,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "cc_fee_late_fee_rules",
                    "paramValueType": "default",
                    "paramValue": "[{\"method\":\"tier\",\"ruleDetailList\":[{\"fixedAmount\":0,\"leftMargin\":0,\"rate\":0,\"rightMargin\":999},{\"fixedAmount\":0,\"leftMargin\":999,\"rate\":1,\"rightMargin\":3500},{\"fixedAmount\":3500,\"leftMargin\":3500,\"rate\":0,\"rightMargin\":-1}]},{\"method\":\"direct\",\"ruleDetailList\":[{\"fixedAmount\":0,\"leftMargin\":0,\"rate\":0,\"rightMargin\":5000},{\"fixedAmount\":10000,\"leftMargin\":5000,\"rate\":0,\"rightMargin\":-1}]}]",
                    "paramDesc": "late fee rules",
                    "effectTimeStartLocal": "2022-12-15 13:40:52",
                    "effectTimeEndLocal": "2022-12-15 13:40:52",
                    "priority": 1,
                    "version": 1,
                    "creator": "harvey",
                    "modifier": "harvey",
                    "createTimeLocal": "2022-12-15 13:40:52",
                    "createTimeUtc": "2022-12-15 13:40:52",
                    "updateTimeLocal": "2022-12-15 13:40:52",
                    "updateTimeUtc": "2022-12-15 13:40:52",
                    "isDeleted": 0,
                    "ifNoAvailable": "default",
                    "productCode": "Construye",
                    "paramName": "late feee rule",
                    "module": "Fee"
                },
                {
                    "id": 3,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "cc_tax_vat_rate",
                    "paramValueType": "default",
                    "paramValue": "0.16",
                    "paramDesc": "IVA in spanish. A value-added tax (VAT), known in some countries as a goods and services tax (GST), is a type of tax that is assessed incrementally. ",
                    "effectTimeStartLocal": "2022-12-15 13:40:55",
                    "effectTimeEndLocal": "2022-12-15 13:40:55",
                    "priority": 1,
                    "version": 1,
                    "creator": "daryl",
                    "modifier": "daryl",
                    "createTimeLocal": "2022-12-15 13:40:55",
                    "createTimeUtc": "2022-12-15 13:40:55",
                    "updateTimeLocal": "2022-12-15 13:40:55",
                    "updateTimeUtc": "2022-12-15 13:40:55",
                    "isDeleted": 0,
                    "ifNoAvailable": "default",
                    "productCode": "Construye",
                    "paramName": "Vat Rate",
                    "module": "Statement"
                },
                {
                    "id": 5,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "cc_int_interest_cal_days",
                    "paramValueType": "default",
                    "paramValue": "360",
                    "paramDesc": "days of year",
                    "effectTimeStartLocal": "2022-01-01 00:00:00",
                    "effectTimeEndLocal": "2050-01-01 00:00:00",
                    "priority": 1,
                    "version": 1,
                    "creator": "wade",
                    "modifier": "wade",
                    "createTimeLocal": "2022-12-15 13:41:04",
                    "createTimeUtc": "2022-12-15 13:41:04",
                    "updateTimeLocal": "2022-12-15 13:41:04",
                    "updateTimeUtc": "2022-12-15 13:41:04",
                    "isDeleted": 0,
                    "ifNoAvailable": "default",
                    "productCode": "Construye",
                    "paramName": "Interest Accural Days of Year",
                    "module": "Interest"
                },
                {
                    "id": 7,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "cc_int_interest_cal_days",
                    "paramValueType": "default",
                    "paramValue": "360",
                    "paramDesc": "days of year",
                    "effectTimeStartLocal": "2022-01-01 00:00:00",
                    "effectTimeEndLocal": "2050-01-01 00:00:00",
                    "priority": 1,
                    "version": 1,
                    "creator": "daryl",
                    "modifier": "daryl",
                    "createTimeLocal": "2022-12-15 13:41:04",
                    "createTimeUtc": "2022-12-15 13:41:04",
                    "updateTimeLocal": "2022-12-15 13:41:04",
                    "updateTimeUtc": "2022-12-15 13:41:04",
                    "isDeleted": 0,
                    "ifNoAvailable": "default",
                    "productCode": "Diamond",
                    "paramName": "Interest Accural Days of Year",
                    "module": "Interest"
                },
                {
                    "id": 9,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "cc_int_interest_cal_days_of_month",
                    "paramValueType": "default",
                    "paramValue": "30",
                    "paramDesc": "Daily Real Interest= Monthly Real Interest/30",
                    "effectTimeStartLocal": "2022-01-01 00:00:00",
                    "effectTimeEndLocal": "2050-01-01 00:00:00",
                    "priority": 1,
                    "version": 1,
                    "creator": "wade",
                    "modifier": "wade",
                    "createTimeLocal": "2022-12-15 13:41:05",
                    "createTimeUtc": "2022-12-15 13:41:05",
                    "updateTimeLocal": "2022-12-15 13:41:05",
                    "updateTimeUtc": "2022-12-15 13:41:05",
                    "isDeleted": 0,
                    "ifNoAvailable": "default",
                    "productCode": "Construye",
                    "paramName": "Interest Accural Days of Month",
                    "module": "Interest"
                },
                {
                    "id": 11,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "cc_int_interest_cal_days_of_month",
                    "paramValueType": "default",
                    "paramValue": "30",
                    "paramDesc": "Daily Real Interest= Monthly Real Interest/30",
                    "effectTimeStartLocal": "2022-01-01 00:00:00",
                    "effectTimeEndLocal": "2050-01-01 00:00:00",
                    "priority": 1,
                    "version": 1,
                    "creator": "wade",
                    "modifier": "wade",
                    "createTimeLocal": "2022-12-15 13:41:05",
                    "createTimeUtc": "2022-12-15 13:41:05",
                    "updateTimeLocal": "2022-12-15 13:41:05",
                    "updateTimeUtc": "2022-12-15 13:41:05",
                    "isDeleted": 0,
                    "ifNoAvailable": "default",
                    "productCode": "Diamond",
                    "paramName": "Interest Accural Days of Month",
                    "module": "Interest"
                },
                {
                    "id": 13,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "cc_int_interest_cal_months",
                    "paramValueType": "default",
                    "paramValue": "12",
                    "paramDesc": "Monthly Real Interest= APR/12 - inflation_rate",
                    "effectTimeStartLocal": "2022-01-01 00:00:00",
                    "effectTimeEndLocal": "2050-01-01 00:00:00",
                    "priority": 1,
                    "version": 1,
                    "creator": "wade",
                    "modifier": "wade",
                    "createTimeLocal": "2022-12-15 13:41:05",
                    "createTimeUtc": "2022-12-15 13:41:05",
                    "updateTimeLocal": "2022-12-15 13:41:05",
                    "updateTimeUtc": "2022-12-15 13:41:05",
                    "isDeleted": 0,
                    "ifNoAvailable": "default",
                    "productCode": "Construye",
                    "paramName": "Interest Accural Months of Year",
                    "module": "Interest"
                },
                {
                    "id": 15,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "cc_int_interest_cal_months",
                    "paramValueType": "default",
                    "paramValue": "12",
                    "paramDesc": "Monthly Real Interest= APR/12 - inflation_rate",
                    "effectTimeStartLocal": "2022-01-01 00:00:00",
                    "effectTimeEndLocal": "2050-01-01 00:00:00",
                    "priority": 1,
                    "version": 1,
                    "creator": "wade",
                    "modifier": "wade",
                    "createTimeLocal": "2022-12-15 13:41:05",
                    "createTimeUtc": "2022-12-15 13:41:05",
                    "updateTimeLocal": "2022-12-15 13:41:05",
                    "updateTimeUtc": "2022-12-15 13:41:05",
                    "isDeleted": 0,
                    "ifNoAvailable": "default",
                    "productCode": "Diamond",
                    "paramName": "Interest Accural Months of Year",
                    "module": "Interest"
                },
                {
                    "id": 17,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "cc_int_segments",
                    "paramValueType": "default",
                    "paramValue": "[\"default\"]",
                    "paramDesc": "\"Segments\" means the different parts of your Account. We may establish that are subject to unique APRs, pricing, or other terms. We create these parts of your Account for such things as your purchases, Balance Transfers, Cash Advances and Special Transfers. The sum of your Segment balances equals your total Account balance.",
                    "effectTimeStartLocal": "2022-01-01 00:00:00",
                    "effectTimeEndLocal": "2050-01-01 00:00:00",
                    "priority": 1,
                    "version": 1,
                    "creator": "wade",
                    "modifier": "wade",
                    "createTimeLocal": "2022-12-15 13:41:05",
                    "createTimeUtc": "2022-12-15 13:41:05",
                    "updateTimeLocal": "2022-12-15 13:41:05",
                    "updateTimeUtc": "2022-12-15 13:41:05",
                    "isDeleted": 0,
                    "ifNoAvailable": "default",
                    "productCode": "Construye",
                    "paramName": "Interest Segment Type",
                    "module": "Interest"
                },
                {
                    "id": 19,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "cc_int_segments",
                    "paramValueType": "default",
                    "paramValue": "[\"default\"]",
                    "paramDesc": "\"Segments\" means the different parts of your Account. We may establish that are subject to unique APRs, pricing, or other terms. We create these parts of your Account for such things as your purchases, Balance Transfers, Cash Advances and Special Transfers. The sum of your Segment balances equals your total Account balance.",
                    "effectTimeStartLocal": "2022-01-01 00:00:00",
                    "effectTimeEndLocal": "2050-01-01 00:00:00",
                    "priority": 1,
                    "version": 1,
                    "creator": "wade",
                    "modifier": "wade",
                    "createTimeLocal": "2022-12-15 13:41:06",
                    "createTimeUtc": "2022-12-15 13:41:06",
                    "updateTimeLocal": "2022-12-15 13:41:06",
                    "updateTimeUtc": "2022-12-15 13:41:06",
                    "isDeleted": 0,
                    "ifNoAvailable": "default",
                    "productCode": "Diamond",
                    "paramName": "Interest Segment Type",
                    "module": "Interest"
                },
                {
                    "id": 21,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "cc_int_segment_tx_map",
                    "paramValueType": "default",
                    "paramValue": "[{\"excludeTypes\":[],\"segmentCode\":\"default\",\"txTypes\":[\"PURCHASE\",\"CASH_ADVANCE\",\"ADJ_PRINCIPAL\",\"BALANCE_INQUIRY\",\"INS_CANCEL_PRIN\"]}]",
                    "paramDesc": "segment tx mapping",
                    "effectTimeStartLocal": "2022-01-01 00:00:00",
                    "effectTimeEndLocal": "2050-01-01 00:00:00",
                    "priority": 1,
                    "version": 1,
                    "creator": "wade",
                    "modifier": "wade",
                    "createTimeLocal": "2022-12-15 13:41:06",
                    "createTimeUtc": "2022-12-15 13:41:06",
                    "updateTimeLocal": "2023-11-24 03:33:47",
                    "updateTimeUtc": "2023-11-24 09:33:47",
                    "isDeleted": 0,
                    "ifNoAvailable": "default",
                    "productCode": "Construye",
                    "paramName": "segment tx mapping",
                    "module": "Interest"
                },
                {
                    "id": 23,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "cc_int_segment_tx_map",
                    "paramValueType": "default",
                    "paramValue": "[{\"excludeTypes\":[],\"segmentCode\":\"default\",\"txTypes\":[\"PURCHASE\",\"CASH_ADVANCE\",\"ADJ_PRINCIPAL\",\"BALANCE_INQUIRY\",\"INS_CANCEL_PRIN\"]}]",
                    "paramDesc": "segment tx mapping",
                    "effectTimeStartLocal": "2022-01-01 00:00:00",
                    "effectTimeEndLocal": "2050-01-01 00:00:00",
                    "priority": 1,
                    "version": 1,
                    "creator": "wade",
                    "modifier": "wade",
                    "createTimeLocal": "2022-12-15 13:41:06",
                    "createTimeUtc": "2022-12-15 13:41:06",
                    "updateTimeLocal": "2023-11-24 03:33:47",
                    "updateTimeUtc": "2023-11-24 09:33:47",
                    "isDeleted": 0,
                    "ifNoAvailable": "default",
                    "productCode": "Diamond",
                    "paramName": "segment tx mapping",
                    "module": "Interest"
                },
                {
                    "id": 25,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "cc_int_tx_segment_map",
                    "paramValueType": "default",
                    "paramValue": "{\"PURCHASE\":\"default\",\"CASH_ADVANCE\":\"default\",\"FEE\":\"default\"}",
                    "paramDesc": "Mapping Relation ship between the transaction and interest segment type.",
                    "effectTimeStartLocal": "2022-01-01 00:00:00",
                    "effectTimeEndLocal": "2050-01-01 00:00:00",
                    "priority": 1,
                    "version": 1,
                    "creator": "wade",
                    "modifier": "wade",
                    "createTimeLocal": "2022-12-15 13:41:06",
                    "createTimeUtc": "2022-12-15 13:41:06",
                    "updateTimeLocal": "2022-12-15 13:41:06",
                    "updateTimeUtc": "2022-12-15 13:41:06",
                    "isDeleted": 0,
                    "ifNoAvailable": "default",
                    "productCode": "Construye",
                    "paramName": "Transaction Segment Map",
                    "module": "Interest"
                },
                {
                    "id": 27,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "cc_int_tx_segment_map",
                    "paramValueType": "default",
                    "paramValue": "{\"PURCHASE\":\"default\",\"CASH_ADVANCE\":\"default\",\"FEE\":\"default\"}",
                    "paramDesc": "Mapping Relation ship between the transaction and interest segment type.",
                    "effectTimeStartLocal": "2022-01-01 00:00:00",
                    "effectTimeEndLocal": "2050-01-01 00:00:00",
                    "priority": 1,
                    "version": 1,
                    "creator": "wade",
                    "modifier": "wade",
                    "createTimeLocal": "2022-12-15 13:41:06",
                    "createTimeUtc": "2022-12-15 13:41:06",
                    "updateTimeLocal": "2022-12-15 13:41:06",
                    "updateTimeUtc": "2022-12-15 13:41:06",
                    "isDeleted": 0,
                    "ifNoAvailable": "default",
                    "productCode": "Diamond",
                    "paramName": "Transaction Segment Map",
                    "module": "Interest"
                },
                {
                    "id": 29,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "post_currency_code",
                    "paramValueType": "default",
                    "paramValue": "MXN",
                    "paramDesc": "post_currency_code",
                    "effectTimeStartLocal": null,
                    "effectTimeEndLocal": null,
                    "priority": 1,
                    "version": 0,
                    "creator": "ParamWriter",
                    "modifier": "ParamWriter",
                    "createTimeLocal": "2022-12-01 07:08:17",
                    "createTimeUtc": "2022-12-01 13:08:17",
                    "updateTimeLocal": "2022-12-01 07:08:17",
                    "updateTimeUtc": "2022-12-01 13:08:17",
                    "isDeleted": 0,
                    "ifNoAvailable": "",
                    "productCode": "STC001",
                    "paramName": "post_currency_code",
                    "module": "Common"
                },
                {
                    "id": 31,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "card_type",
                    "paramValueType": "default",
                    "paramValue": "PHYSICAL",
                    "paramDesc": "card_type",
                    "effectTimeStartLocal": null,
                    "effectTimeEndLocal": null,
                    "priority": 1,
                    "version": 0,
                    "creator": "ParamWriter",
                    "modifier": "ParamWriter",
                    "createTimeLocal": "2022-12-01 07:08:18",
                    "createTimeUtc": "2022-12-01 13:08:18",
                    "updateTimeLocal": "2022-12-01 07:08:18",
                    "updateTimeUtc": "2022-12-01 13:08:18",
                    "isDeleted": 0,
                    "ifNoAvailable": "",
                    "productCode": "STC001",
                    "paramName": "card_type",
                    "module": "Common"
                },
                {
                    "id": 33,
                    "tenantId": "STMXFINCORE0",
                    "entityId": "MXCC20220000",
                    "paramKey": "product_type",
                    "paramValueType": "default",
                    "paramValue": "CREDIT",
                    "paramDesc": "product_type",
                    "effectTimeStartLocal": null,
                    "effectTimeEndLocal": null,
                    "priority": 1,
                    "version": 0,
                    "creator": "ParamWriter",
                    "modifier": "ParamWriter",
                    "createTimeLocal": "2022-12-01 07:08:19",
                    "createTimeUtc": "2022-12-01 13:08:19",
                    "updateTimeLocal": "2022-12-01 07:08:19",
                    "updateTimeUtc": "2022-12-01 13:08:19",
                    "isDeleted": 0,
                    "ifNoAvailable": "",
                    "productCode": "STC001",
                    "paramName": "product_type",
                    "module": "Common"
                }
            ]
        },
        duplicateProduct(item) {
            const productStore = useProductStore();
            productStore.setProductInfo(item);
            this.$router.push({
                name: 'new-product',
            });
        },
        viewProduct(item) {
            const productStore = useProductStore();
            productStore.setProductInfo(item);
            this.$router.push({
                name: 'view-product',
            });
        },
        findSystemParams() {
            let productCodes = new Set(this.products.map(product => product.productCode));
            this.sysParam = this.paramList.filter(
                param => !productCodes.has(param.productCode)
            );
        }
    },
};
</script>

<style scoped>
table {
    width: 100%;
    border-collapse: collapse;
}

th,
td {
    padding: 8px;
    border: 1px solid #ddd;
    text-align: left;
}

th {
    background-color: #f2f2f2;
    cursor: pointer;
}

th span {
    margin-left: 5px;
    font-size: 12px;
    color: gray;
}

button {
    padding: 5px 10px;
    border: none;
    border-radius: 5px;
    cursor: pointer;
}
</style>