({
    /**
     * Checks if a category is valid
     * @param      {String}   category  The category
     * @return     {boolean}
     */
    validateCategory : function(category) {
        var okCategories = [
            "Retail",
            "Commercial",
            "Wealth"
        ];
        if (okCategories.indexOf(category) >= 0) return category;
        return 'Retail';
    }
})