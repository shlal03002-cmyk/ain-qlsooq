# DATABASE PLAN

1. products
2. variants
3. stores
4. offers
5. price_history

العلاقة الأساسية:
Product -> Variants
Product -> Offers -> Store
Offer -> Price History

الإصدار الحالي يستخدم `products.json` فقط لتشغيل النموذج الأولي بسرعة.
