// ═══════════════════════════════════════════════════════════════
// src/shared/ai/claude.js — Claude SDK wrapper
// ═══════════════════════════════════════════════════════════════

const Anthropic = require('@anthropic-ai/sdk');
const config = require('../../core/config');
const logger = require('../../core/utils/logger');

const client = new Anthropic({
  apiKey: config.anthropic.apiKey
});

/**
 * Claude ilə sorğu göndərir
 * @param {string} systemPrompt — sistem təlimatı
 * @param {string} userPrompt — istifadəçi sorğusu
 * @param {object} options — əlavə konfiqurasiya
 * @returns {Promise<string>} Claude-un cavabı
 */
const ask = async (systemPrompt, userPrompt, options = {}) => {
  const start = Date.now();

  try {
    const response = await client.messages.create({
      model: options.model || config.anthropic.model,
      max_tokens: options.maxTokens || config.anthropic.maxTokens,
      system: systemPrompt,
      messages: [{ role: 'user', content: userPrompt }]
    });

    const duration = Date.now() - start;
    const text = response.content[0].text;

    logger.info(`🤖 Claude (${duration}ms): ${response.usage.input_tokens}→${response.usage.output_tokens} tokens`);
    return text;
  } catch (err) {
    logger.error(`❌ Claude xətası: ${err.message}`);
    throw err;
  }
};

/**
 * Layihə məlumatı əsasında AI təhlil generasiya edir
 */
const analyzeProject = async (projectData) => {
  const systemPrompt = `Sən Azərbaycan Respublikası təhsil obyektlərinin təmir-tikinti layihələri üzrə təcrübəli mühəndis və idarəçisən.
Sənin vəzifən: verilmiş layihə məlumatlarını təhlil etmək və aşağıdakıları müəyyən etmək:
1. Potensial risklər
2. Büdcə sapma ehtimalı
3. Müddət uyğunsuzluqları
4. Tövsiyələr

Cavabı Azərbaycan dilində, strukturlaşdırılmış formada ver.`;

  const userPrompt = `Layihə məlumatı:
${JSON.stringify(projectData, null, 2)}

Bu layihəni təhlil et və risklərlə birlikdə tövsiyələrini ver.`;

  return await ask(systemPrompt, userPrompt);
};

module.exports = { ask, analyzeProject };
