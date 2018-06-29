//
//  BadgeAndHeatmapCell.swift
//  PhishOD
//
//  Created by Jacob Farkas on 6/29/18.
//  Copyright © 2018 Alec Gorge. All rights reserved.
//

import Foundation
import TDBadgedCell

@objc class BadgeAndHeatmapCell : TDBadgedCell {
    @objc func updateHeatmapLabel(value: Double) {
        self.heatmapView.isHidden = value < 0.6 || UserDefaults.standard.bool(forKey: "heatmaps.enabled")
        let max_height : CGFloat = self.heatmapView.frame.size.height;
        var hm = self.heatmapValue.frame;
        hm.origin.y = CGFloat(Double(max_height) * (1.0 - value));
        self.heatmapValue.frame = hm;
    }
    
    fileprivate let heatmapHeight : CGFloat = 36
    fileprivate let heatmapWidth : CGFloat = 4
    
    fileprivate lazy var heatmapView : UIView = {
        var heatmapView = UIView(frame: CGRect(x: 0, y: 0, width: self.heatmapWidth, height: self.heatmapHeight))
        heatmapView.clipsToBounds = true
        
        // (farkas) This is a hack but I don't want to create a constants file right now
        heatmapView.backgroundColor = UIColor(red: 0.0, green: 183.0/255.0, blue: 132.0/255.0, alpha: 0.2)
        heatmapView.addSubview(self.heatmapValue)
        return heatmapView
    }()
    
    fileprivate lazy var heatmapValue : UIView = {
        var heatmapValue = UIView(frame: CGRect(x: 0, y: 20, width: self.heatmapWidth, height: self.heatmapHeight))
        heatmapValue.backgroundColor = UIColor(red: 0.0, green: 128.0/255.0, blue: 95.0/255.0, alpha: 1.0)
        return heatmapValue
    }()
    
    fileprivate func configureHeatmap() {
        self.contentView.addSubview(self.heatmapView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let h : CGFloat     = self.frame.size.height
        let w : CGFloat     = self.frame.size.width
        let hm_h : CGFloat  = self.heatmapView.frame.size.height
        let hm_x : CGFloat  = w - 38.0
        let hm_y : CGFloat  = h - hm_h - (h - hm_h)/2.0
        
        self.heatmapView.frame = CGRect(x: hm_x, y: hm_y, width: 4, height: hm_h)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureHeatmap()
    }
    
    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureHeatmap()
    }
}
