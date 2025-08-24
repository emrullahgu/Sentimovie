
# Model Card — Sentimovie: IMDb Duygu Analizi

**Geliştirici:** Emrullah Günay  
**Versiyon:** 0.2.0  
**Son Güncelleme:** 2024

## 📋 Model Bilgileri

### Temel Bilgiler
- **Model Adı:** Sentimovie IMDb Sentiment Classifier
- **Model Türü:** Fine-tuned DistilBERT
- **Base Model:** `distilbert-base-uncased`
- **Task:** Binary Sentiment Classification (IMDb Movie Reviews)
- **Dil:** İngilizce
- **Model Boyutu:** ~260 MB

### Mimari
- **Architecture:** DistilBERT (Distilled BERT)
- **Layers:** 6 transformer layers
- **Hidden Size:** 768
- **Attention Heads:** 12
- **Parameters:** ~66M (trainable)

## 🎯 Kullanım Amacı

### Ana Amaç
IMDb film yorumlarında pozitif/negatif duygu sınıflandırması yapmak.

### Kullanım Senaryoları
- Film yorum analizi
- Sosyal medya sentiment analizi
- Customer feedback analizi
- Content moderation

### Sınırlamalar
- Sadece İngilizce metinler
- Binary classification (pozitif/negatif)
- IMDb yorumlarına özel eğitim
- Kısa metinler için optimize edilmiş

## 📊 Performans Metrikleri

### Test Sonuçları (2% veri, 1 epoch)
| Metric | Value |
|--------|-------|
| Accuracy | 87.5% |
| F1 Macro | 87.3% |
| F1 Weighted | 87.8% |
| Precision Macro | 87.8% |
| Recall Macro | 87.1% |

### Sınıf Bazında Performans
- **Negatif Sınıf (0):** F1: 87.2%
- **Pozitif Sınıf (1):** F1: 87.4%

> **Not:** Bu metrikler küçük veri örneği üzerinde kısa eğitim süresi ile elde edilmiştir.

## 🗂️ Veri Kümesi

### Eğitim Verisi
- **Kaynak:** IMDb Large Movie Review Dataset
- **Boyut:** 25,000 eğitim örneği (2% sample)
- **Format:** Text + Binary Label
- **Dil:** İngilizce

### Test Verisi
- **Boyut:** 25,000 test örneği (2% sample)
- **Split:** Orijinal veri kümesindeki ayrım

### Veri Ön İşleme
- **Tokenization:** DistilBERT tokenizer
- **Max Length:** 128 tokens
- **Padding:** Max length padding
- **Truncation:** Long sequences truncated

## 🏗️ Eğitim Detayları

### Hiperparametreler
```yaml
Model: distilbert-base-uncased
Epochs: 1.0
Learning Rate: 5e-5
Batch Size: 8
Max Length: 128
Weight Decay: 0.01
Warmup Steps: 100
```

### Eğitim Ortamı
- **Hardware:** CPU-only
- **Framework:** PyTorch + Transformers
- **Optimizer:** AdamW
- **Scheduler:** Linear warmup + decay
- **Loss Function:** CrossEntropyLoss

### Eğitim Süresi
- **2% veri, 1 epoch:** ~2-5 dakika (CPU)
- **Tam veri, 3 epochs:** ~2-4 saat (CPU)

## 🚀 Kullanım

### API Endpoint
```bash
POST /predict
{
  "text": "This movie was absolutely fantastic!"
}
```

### Response Format
```json
{
  "label": 1,
  "probability": [0.123, 0.877],
  "confidence": 0.877,
  "text": "This movie was absolutely fantastic!"
}
```

### Batch Prediction
```bash
POST /batch-predict
[
  "Great movie!",
  "Terrible movie!",
  "Okay movie."
]
```

## 🔧 Teknik Detaylar

### Model Yükleme
```python
from transformers import AutoTokenizer, AutoModelForSequenceClassification

tokenizer = AutoTokenizer.from_pretrained("models/distilbert-imdb")
model = AutoModelForSequenceClassification.from_pretrained("models/distilbert-imdb")
```

### Inference
```python
inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True, max_length=128)
with torch.no_grad():
    outputs = model(**inputs)
    probabilities = torch.softmax(outputs.logits, dim=-1)
    prediction = torch.argmax(outputs.logits, dim=-1)
```

### Memory Requirements
- **Model Loading:** ~260 MB RAM
- **Inference:** ~512 MB RAM (batch size 1)
- **Training:** ~2 GB RAM (batch size 8)

## 📈 Model Versiyonları

### v0.1.0 (Base)
- Base DistilBERT model
- No fine-tuning
- Basic sentiment classification

### v0.2.0 (Current)
- Fine-tuned on IMDb data
- Improved accuracy
- Better handling of movie review language

## 🔍 Model Analizi

### Güçlü Yönler
- Hızlı inference (CPU-friendly)
- Küçük model boyutu
- İyi accuracy/performance ratio
- Stable predictions

### Zayıf Yönler
- Limited to English
- Binary classification only
- Short text optimization
- Domain-specific (movie reviews)

### Bias ve Adalet
- IMDb veri kümesindeki potansiyel bias'lar
- English-centric training data
- Movie review domain bias

## 🛡️ Güvenlik ve Etik

### Veri Gizliliği
- Training data: Public IMDb dataset
- No personal information stored
- Model does not memorize training examples

### Kullanım Kısıtlamaları
- Research and educational purposes
- Commercial use requires evaluation
- Not for critical decision making

### Potansiyel Riskler
- Misclassification of sarcasm
- Cultural bias in sentiment
- Overconfidence in predictions

## 📚 Referanslar

### Papers
- [DistilBERT: Distilling BERT for NLP](https://arxiv.org/abs/1910.01108)
- [BERT: Pre-training of Deep Bidirectional Transformers](https://arxiv.org/abs/1810.04805)

### Datasets
- [IMDb Large Movie Review Dataset](https://ai.stanford.edu/~amaas/data/sentiment/)

### Tools
- [Hugging Face Transformers](https://huggingface.co/transformers/)
- [PyTorch](https://pytorch.org/)

## 📞 İletişim

**Model Geliştirici:** Emrullah Günay  
**GitHub:** [@emrullahgunay](https://github.com/emrullahgunay)  
**Email:** [emrullah@example.com](mailto:emrullah@example.com)

---

*Bu model card, modelin şeffaf ve sorumlu kullanımını desteklemek için hazırlanmıştır.*
