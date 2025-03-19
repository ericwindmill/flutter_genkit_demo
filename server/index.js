"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const dev_local_vectorstore_1 = require("@genkit-ai/dev-local-vectorstore");
const express_1 = require("@genkit-ai/express");
const googleai_1 = require("@genkit-ai/googleai");
const vertexai_1 = __importStar(require("@genkit-ai/vertexai"));
const fs_1 = require("fs");
const beta_1 = require("genkit/beta");
const model_1 = require("genkit/model");
const retriever_1 = require("genkit/retriever");
const path_1 = require("path");
const ai = (0, beta_1.genkit)({
    plugins: [
        (0, googleai_1.googleAI)({
            apiKey: process.env.GOOGLE_GENAI_API_KEY,
        }),
        (0, vertexai_1.default)({
            projectId: process.env.GCP_PROJECT_ID,
            location: process.env.GCP_LOCATION,
        }),
        (0, dev_local_vectorstore_1.devLocalVectorstore)([
            {
                indexName: 'products',
                embedder: vertexai_1.textEmbedding004,
            },
        ]),
    ],
    // turn down the creativity of the model so that it doesn't make up product
    // names or details
    model: googleai_1.gemini20Flash.withConfig({ temperature: 0.3 }),
});
// *** Flow #1: Indexing the product catalog ***
const loadProducts = () => {
    return JSON.parse((0, fs_1.readFileSync)((0, path_1.join)(__dirname, 'gardening-products.json'), 'utf-8'));
};
const productsIndexer = (0, dev_local_vectorstore_1.devLocalIndexerRef)('products');
const productsRetriever = (0, dev_local_vectorstore_1.devLocalRetrieverRef)('products');
const indexProducts = ai.defineFlow({
    name: "indexProducts",
    inputSchema: beta_1.z.void(),
    outputSchema: beta_1.z.object({
        success: beta_1.z.boolean(),
        message: beta_1.z.string(),
    }),
}, () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        console.log('Indexing products from gardening-products.json');
        // Convert products into documents
        const products = loadProducts();
        const documents = products.map((product) => retriever_1.Document.fromText(product.description, {
            product: product.product,
            manufacturer: product.manufacturer,
            description: product.description,
            cost: product.cost,
            image: product.image,
            id: product.id,
        }));
        // Add documents to the index
        yield ai.index({ indexer: productsIndexer, documents });
        return {
            success: true,
            message: `Successfully indexed ${documents.length} products`,
        };
    }
    catch (error) {
        return {
            success: false,
            message: `Failed to index products: ${error}`,
        };
    }
}));
// *** Flow #2: Q&A between the model and the user ***
const choiceInterrupt = ai.defineInterrupt({
    name: 'choice',
    description: 'Asks the user a question with a list of choices',
    inputSchema: beta_1.z.object({
        question: beta_1.z.string().describe("The model's follow-up question."),
        choices: beta_1.z.array(beta_1.z.string()).describe("The list of choices."),
    }),
    outputSchema: beta_1.z.string().describe("The user's choice."),
});
const imageInterrupt = ai.defineInterrupt({
    name: 'image',
    description: 'Asks the user to take a picture of their plant',
    inputSchema: beta_1.z.object({
        question: beta_1.z.string().describe("The model's follow-up question."),
    }),
    outputSchema: beta_1.z.string().describe("base64 encoded image."),
});
const rangeInterrupt = ai.defineInterrupt({
    name: 'range',
    description: 'Asks the user to choose a number in a range',
    inputSchema: beta_1.z.object({
        question: beta_1.z.string().describe("The model's follow-up question."),
        min: beta_1.z.number().describe("The minimum value of the range."),
        max: beta_1.z.number().describe("The maximum value of the range."),
    }),
    outputSchema: beta_1.z.number().describe("A number in the range."),
});
const productLookupTool = ai.defineTool({
    name: 'productLookup',
    description: 'Find the top product that matches a given description',
    inputSchema: beta_1.z.object({
        description: beta_1.z.string().describe('The description of the product')
    }),
    outputSchema: beta_1.z.object({
        product: beta_1.z.string().describe('The name of the product'),
        manufacturer: beta_1.z.string().describe('The manufacturer of the product'),
        cost: beta_1.z.number().describe('The cost of the product'),
        image: beta_1.z.string().describe('The image of the product'),
    }),
}, (input) => __awaiter(void 0, void 0, void 0, function* () {
    const docs = yield ai.retrieve({
        retriever: productsRetriever,
        query: input.description,
        options: { k: 1 },
    });
    const metadata = docs[0].metadata;
    const product = {
        product: (metadata === null || metadata === void 0 ? void 0 : metadata.product) || "Unknown",
        manufacturer: (metadata === null || metadata === void 0 ? void 0 : metadata.manufacturer) || "Unknown",
        cost: (metadata === null || metadata === void 0 ? void 0 : metadata.cost) || 0,
        image: (metadata === null || metadata === void 0 ? void 0 : metadata.image) || "",
    };
    console.log('PRODUCT:');
    console.log(JSON.stringify(product, null, 2));
    return product;
}));
const gtInputSchema = beta_1.z.object({
    prompt: beta_1.z.string().optional(),
    messages: beta_1.z.array(beta_1.MessageSchema).optional(),
    resume: beta_1.z.object({ respond: beta_1.z.array(model_1.ToolResponsePartSchema) }).optional(),
});
const gtOutputSchema = beta_1.z.object({
    messages: beta_1.z.array(beta_1.MessageSchema),
});
const gtSystem = `
You are GreenThumb, an expert gardener assistant integrated into an app that
helps people with their plants. A user will ask you questions about gardening.

You must follow these steps exactly:
1. Ask clarifying questions to the user about their situation.
-	Use the choice, image, and range tools to ask these questions.
- Make sure to use each tool at least once.
-	Do not ask any questions in plain text. All clarifying questions must be asked by calling the appropriate interrupt tool(s).

2. Form a description for each of one or more products that you recommend.
- Use the information you have gathered from the user to form a description for each product.
- The product descriptions MUST NOT contain any product names, manufacturer names, or prices. Those will be looked up in the next step.

3. Use the descriptions to lookup products that match the descriptions.
-	You must call the productLookup tool to fetch product details that match product descriptions you've created.
-	For each product you recommend, you must pass a relevant query or description into the productLookup tool.
-	DO NOT invent product names, DO NOT invent product data, and DO NOT invent images. ONLY use the productLookup tool to find products.

4. Your final response (after you've received the results from the productLookup tool) must follow the Markdown format below:

    [put your overall recommendation here; be clear and concise].

    # [product 1]
    **$[cost]** - from [manufacturer]

    ![](image)

    # [product 2]
    **$[cost]** - from [manufacturer]

    ![](image)

    ...
`;
const greenThumb = ai.defineFlow({
    name: "greenThumb",
    inputSchema: gtInputSchema,
    outputSchema: gtOutputSchema,
}, (_a) => __awaiter(void 0, [_a], void 0, function* ({ prompt, messages, resume }) {
    const response = yield ai.generate(Object.assign(Object.assign({}, (messages && messages.length > 0 ? {} : { system: gtSystem })), { prompt, tools: [choiceInterrupt, imageInterrupt, rangeInterrupt, productLookupTool], messages,
        resume }));
    return { messages: response.messages };
}));
(0, express_1.startFlowServer)({
    flows: [indexProducts, greenThumb],
});
//# sourceMappingURL=index.js.map